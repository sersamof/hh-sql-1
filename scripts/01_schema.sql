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
  user_id    serial primary key,
  last_name  varchar(255) not null,
  first_name varchar(255) not null,
  patronymic varchar(255),
  birth_date date,
  registered timestamp    not null, -- храним в UTC, конвертация таймзоны на слое представления
  city_id    int references city (city_id),
  last_login timestamp
);

create table auth_info
(
  user_id  integer     not null references user_info (user_id),
  login    varchar(50) not null unique,
  active   boolean     not null,
  password varchar(60) not null
);

create table flood
(
  flood_id     serial primary key,
  ip           varchar(50) unique,
  login        varchar(50) unique,
  attempts     int       not null,
  last_attempt timestamp not null,
  constraint ip_xor_login_not_null check ((ip is not null or login is not null) and
                                          not (ip is not null and login is not null))
);

create table banned
(
  ip           varchar(50) not null primary key,
  banned_until timestamp   not null
);

create table company
(
  company_id  serial primary key,
  name        varchar(500)  not null,
  description varchar(5000) not null,
  url         varchar(255),
  city_id     int           not null references city (city_id),
  active      boolean       not null,
  registered  timestamp     not null,
  admin       int           not null references user_info (user_id)
);

create table company_hr
(
  company_id int not null references company (company_id),
  user_id    int not null references user_info (user_id)
);

create table vacancy
(
  vacancy_id  serial primary key,
  company_id  int           not null references company (company_id),
  position    varchar(255)  not null,
  description varchar(5000) not null,
  salary_from int,
  salary_to   int,
  experience  experience    not null,
  city_id     int           not null references city (city_id),
  posted      timestamp     not null,
  expired     timestamp     not null
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

create table curriculum_vitae
(
  cv_id       serial primary key,
  user_id     int       not null references user_info (user_id),
  position    varchar(255),
  published   boolean   not null,
  moderated   boolean   not null,
  created     timestamp not null,
  updated     timestamp not null,
  salary_from int,
  salary_to   int,
  public      boolean   not null -- для упрощения видимость только всем / никому
);
create table curriculum_vitae_skills
(
  cv_id    int not null references curriculum_vitae (cv_id),
  skill_id int not null references skill (skill_id),
  primary key (cv_id, skill_id)
);
create table curriculum_vitae_experience
(
  cv_experience_id serial primary key,
  cv_id            int  not null references curriculum_vitae (cv_id),
  company_id       int references company (company_id),
  company_name     varchar(500),
  date_from        date not null,
  date_to          date,
  description      varchar(5000),
  constraint cv_exp_company_not_null check (company_id is not null or company_name is not null)
);

-- в принципе, (vacancy_id, cv_id) - естественный ключ, но в предположении о том,
-- что сообщения и приглашения на вакансию обязательно связаны с откликом,
-- создадим суррогатный ключ для более удобной связи по foreign key
create table vacancy_response
(
  response_id serial primary key,
  vacancy_id  int       not null references vacancy (vacancy_id),
  cv_id       int       not null references curriculum_vitae (cv_id),
  active      boolean   not null,
  send_time   timestamp not null,
  message     varchar(5000)
);
-- возможно стоило бы response_id сдедлать unique, но будем предполагать, что возможно несколько приглашений на один отклик
-- например, в случае несостоявшейся встречи
-- возможно так же unique (response_id, accepted), но по той же причине возможно несколько принятых приглашений
create table invitation
(
  invitation_id      serial primary key,
  response_id        int          not null references vacancy_response (response_id),
  interview_datetime timestamp    not null,
  contact_person     varchar(255) not null,
  contact_phone      varchar(255) not null,
  contact_mail       varchar(255),
  address            varchar(255) not null,
  send_time          timestamp    not null,
  accepted           boolean      not null,
  message            varchar(5000)
);

create table message
(
  message_id  serial primary key,
  user_id     int           not null references user_info (user_id),
  response_id int           not null references vacancy_response (response_id),
  send_time   timestamp     not null,
  message     varchar(5000) not null
);


