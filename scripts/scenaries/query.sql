-- захардкоженные id из 02_data.sql

-- попытка авторизации
select true as success
from auth_info
where login = 'user1'
  and password = 'sfsafafdgdlfkgd'
  and active is true;

-- все активные пользователи с информацией о городе
select u.user_id, ai.login, u.last_name, u.first_name, u.patronymic, c.name
from user_info u
       left join auth_info ai on u.user_id = ai.user_id
       left join city c on c.city_id = u.city_id
where ai.active is true;

-- все активные компании
select company_id, company.name, url, city.name
from company
       left join city on company.city_id = city.city_id
where company.active is true;


-- список hr компании
select company_hr.company_id, company_hr.user_info_id, name as company_name, last_name, first_name, patronymic
from company_hr
       left join company comp on company_hr.company_id = comp.company_id
       left join user_info on company_hr.user_info_id = user_info.user_id
where comp.company_id = 1;

-- активные вакансии компаний
select vacancy.vacancy_id,
       vacancy.position,
       comp.name,
       city.name,
       vacancy.description,
       vacancy.salary_from,
       vacancy.salary_to,
       vacancy.experience,
       vacancy.posted_time,
       vacancy.company_id,
       city.city_id
from vacancy
       left join company comp on vacancy.company_id = comp.company_id
       left join city on comp.city_id = city.city_id
where expired_time > now();

-- необходимые скилы по вакансии
select vacancy_id, s.skill_id, s.title
from vacancy_skills
       left join skill s on vacancy_skills.skill_id = s.skill_id
where vacancy_id = 3;

-- вакансии для пользователя по скиллам
with user_skills as (select distinct skill_id, user_info_id
                     from cv_skills as cv_skills
                            left join cv on cv_skills.cv_id = cv.cv_id)
select vacancy.vacancy_id, vacancy.position, c.name
from vacancy
       left join vacancy_skills vs on vacancy.vacancy_id = vs.vacancy_id
       left join company c on vacancy.company_id = c.company_id
       left join user_skills on vs.skill_id = user_skills.skill_id
where user_info_id = 4
group by vacancy.vacancy_id, c.name;


with user_skills as (select distinct skill_id, user_info_id
                     from cv_skills as cv_skills
                            left join cv on cv_skills.cv_id = cv.cv_id),
     vacancy_ids_by_user as (select distinct vacancy_id, user_info_id
                             from vacancy_skills
                                    left join user_skills on vacancy_skills.skill_id = user_skills.skill_id
     )
select *
from vacancy_ids_by_user
       left join vacancy on vacancy_ids_by_user.vacancy_id = vacancy.vacancy_id
       left join company c on vacancy.company_id = c.company_id
where vacancy_ids_by_user.user_info_id = 4;

-- общий стаж по резюме
select cv_id,
       sum(
           case
             when date_to is null
               then (now()::date - date_from)
             else (date_to - date_from)
             end
         ) days
from cv_experience
group by cv_id;


-- обновление cv
update cv
set position = 'Единичная матрица'
where cv_id = 3;

update cv_experience
set date_to     = '1969-12-29',
    description = 'Начинал работать со скалярами до unix-эпохи.'
where cv_experience_id = 3;

--диалоги
begin transaction;
insert into messages_topic (messages_topic_id, applicant_user_info_id, hr_user_info_id)
values (1, 2, 5);
insert into message (user_info_id, send_time, message, messages_topic_id, sender)
values (2, now(), 'Хочу в новый город!', 1, 'applicant');
insert into vacancy_response (send_time, messages_topic_id, vacancy_id)
values (now(), 1, 2);
commit;

insert into message (user_info_id, send_time, message, messages_topic_id, sender)
values (5, now(), 'Простите, Вы необходимы в Питере.', 1, 'hr');
insert into message (user_info_id, send_time, message, messages_topic_id, sender)
values (2, now(), 'Жаль.', 1, 'applicant');


begin transaction;
insert into messages_topic (messages_topic_id, applicant_user_info_id, hr_user_info_id)
values (2, 3, 4);
insert into message (user_info_id, send_time, message, messages_topic_id, sender)
values (2, now(), 'Смогу быть единицей!', 2, 'applicant');
insert into vacancy_response (send_time, messages_topic_id, vacancy_id)
values (now(), 2, 3);
commit;

begin transaction;
insert into message (user_info_id, send_time, message, messages_topic_id, sender)
values (4, now(), 'Ждем Вас!', 2, 'hr');
insert into invitation (interview_time, send_time, messages_topic_id)
values ('2018-12-30 14:00:00', now(), 2);
commit;


-- отклики пользователя
select *
from vacancy_response
       join messages_topic mt on vacancy_response.messages_topic_id = mt.messages_topic_id
where mt.applicant_user_info_id = 3;

-- приглашения пользователя
select *
from invitation
       join messages_topic mt on invitation.messages_topic_id = mt.messages_topic_id
where mt.applicant_user_info_id = 3;


-- история сообщений в топике
select applicant.last_name || ' ' || applicant.first_name || coalesce(' ' || applicant.patronymic, '') as applicant,
       hr.last_name || ' ' || hr.first_name || coalesce(' ' || hr.patronymic, '')                      as hr,
       message.message,
       message.send_time,
       message.sender
from message
       join messages_topic mt on message.messages_topic_id = mt.messages_topic_id
       join user_info applicant on mt.applicant_user_info_id = applicant.user_id
       join user_info hr on mt.hr_user_info_id = hr.user_id
where mt.messages_topic_id = 1;
