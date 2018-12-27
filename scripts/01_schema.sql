---
--спроектировать бд
--пользователи (логин, пароль, время регистрации, время последнего логина)
--вакансии (компания, должность, описание, вилка зп, требуемый опыт работы, требуемые скилы, время размещения, время окончания публикации)
--резюме (должность, фио, возраст, вилка зп, опыт работы, скилы)
--отклики/приглашения/сообщения (по паре резюме-вакансия)
---

---
--результат дз
--графический файл - схема бд
--файл с sql-скриптом для создания всей схемы
--файл с sql-скриптом для заполнения таблиц (1-5 строк по каждой таблице)
--сценарии использования и запросы
---


create type experience as enum ('none', 'less than 1', 'between 1 and 3', 'between 3 and 6', 'more than 6');

-- ооочень наивно, но для демонстрации подойдет
create table city
(
  city_id int primary key,
  name    varchar(50) not null
);

create table user_info
(
  user_id         serial primary key,
  last_name       varchar(255) not null,
  first_name      varchar(255) not null,
  patronymic      varchar(255),
  birth_date      date,
  registered_time timestamp    not null, -- храним в UTC, конвертация таймзоны на слое представления
  city_id         int references city (city_id),
  last_login_time timestamp
);

create table auth_info
(
  user_id  integer     not null references user_info (user_id),
  login    varchar(50) not null unique,
  active   boolean     not null,
  password varchar(60) not null
);

create table company
(
  company_id       serial primary key,
  name             varchar(500)  not null,
  description      varchar(5000) not null,
  url              varchar(255),
  city_id          int           not null references city (city_id),
  active           boolean       not null,
  registered_time  timestamp     not null,
  mcp_user_info_id int           not null references user_info (user_id)
);

create table company_hr
(
  company_id   int not null references company (company_id),
  user_info_id int not null references user_info (user_id),
  primary key (company_id, user_info_id)

);

create table vacancy
(
  vacancy_id   serial primary key,
  company_id   int           not null references company (company_id),
  position     varchar(255)  not null,
  description  varchar(5000) not null,
  salary_from  int,
  salary_to    int,
  experience   experience    not null,
  city_id      int           not null references city (city_id),
  posted_time  timestamp     not null,
  expired_time timestamp     not null
);

create table skill
(
  skill_id serial primary key,
  title    varchar(50) not null
);

create table vacancy_skills
(
  vacancy_id int not null references vacancy (vacancy_id),
  skill_id   int not null references skill (skill_id),
  primary key (vacancy_id, skill_id)
);

create table cv
(
  cv_id        serial primary key,
  user_info_id int       not null references user_info (user_id),
  position     varchar(255),
  published    boolean   not null,
  moderated    boolean   not null,
  created_time timestamp not null,
  updated_time timestamp not null,
  salary_from  int,
  salary_to    int,
  visibility   boolean   not null -- для упрощения видимость только всем / никому
);
create table cv_skills
(
  cv_id    int not null references cv (cv_id),
  skill_id int not null references skill (skill_id),
  primary key (cv_id, skill_id)
);
create table cv_experience
(
  cv_experience_id serial primary key,
  cv_id            int  not null references cv (cv_id),
  company_id       int references company (company_id),
  company_name     varchar(500),
  date_from        date not null,
  date_to          date,
  description      varchar(5000),
  constraint cv_exp_company_not_null check (company_id is not null or company_name is not null)
);

create table messages_topic
(
  messages_topic_id      serial primary key,
  applicant_user_info_id int not null references user_info (user_id),
  hr_user_info_id        int not null references user_info (user_id)
);

-- в принципе, (vacancy_id, cv_id) - естественный ключ, но в предположении о том,
-- что сообщения и приглашения на вакансию обязательно связаны с откликом,
-- создадим суррогатный ключ для более удобной связи по foreign key
create table vacancy_response
(
  response_id       serial primary key,
  send_time         timestamp not null,
  vacancy_id        int       not null references vacancy (vacancy_id),
  messages_topic_id int       not null references messages_topic (messages_topic_id)
);
-- возможно стоило бы response_id сдедлать unique, но будем предполагать, что возможно несколько приглашений на один отклик
-- например, в случае несостоявшейся встречи
-- возможно так же unique (response_id, accepted), но по той же причине возможно несколько принятых приглашений
create table invitation
(
  invitation_id     serial primary key,
  interview_time    timestamp not null,
  send_time         timestamp,
  messages_topic_id int       not null references messages_topic (messages_topic_id)
);

-- поскольку в нашей схеме диалог ведется только между 2мя лицами и
-- для упрощения соискателя ведет всегда один и тот же HR, то направление сообщения определяется простым enum
create type user_type as enum ('applicant', 'hr');
create table message
(
  message_id        serial primary key,
  user_info_id      int           not null references user_info (user_id),
  send_time         timestamp     not null,
  message           varchar(5000) not null,
  messages_topic_id int           not null references messages_topic (messages_topic_id),
  sender            user_type     not null
);
