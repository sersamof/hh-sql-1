-- попытка авторизации
select true as success
from auth_info
where login = 'user1'
  and password = crypt('very_strong_pass', password)
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
select company_hr.company_id, company_hr.user_id, name as company_name, last_name, first_name, patronymic
from company_hr
       left join company comp on company_hr.company_id = comp.company_id
       left join user_info on company_hr.user_id = user_info.user_id
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
       vacancy.posted,
       vacancy.company_id,
       city.city_id
from vacancy
       left join company comp on vacancy.company_id = comp.company_id
       left join city on comp.city_id = city.city_id
where expired > now();

-- необходимые скилы по вакансии
select *
from vacancy_skills
       left join skill s on vacancy_skills.skill_id = s.skill_id
where vacancy_id = 3;

-- вакансии для пользователя по скиллам
with user_skills as (select distinct skill_id, user_id
                     from curriculum_vitae_skills as cv_skills
                            left join curriculum_vitae cv on cv_skills.cv_id = cv.cv_id)
select vacancy.vacancy_id, vacancy.position, c.name
from vacancy
       left join vacancy_skills vs on vacancy.vacancy_id = vs.vacancy_id
       left join company c on vacancy.company_id = c.company_id
       left join user_skills on vs.skill_id = user_skills.skill_id
where user_id = 4
group by vacancy.vacancy_id, c.name;


with user_skills as (select distinct skill_id, user_id
                     from curriculum_vitae_skills as cv_skills
                            left join curriculum_vitae cv on cv_skills.cv_id = cv.cv_id),
     vacancy_ids_by_user as (select distinct vacancy_id, user_id
                             from vacancy_skills
                                    left join user_skills on vacancy_skills.skill_id = user_skills.skill_id
     )
select *
from vacancy_ids_by_user
       left join vacancy on vacancy_ids_by_user.vacancy_id = vacancy.vacancy_id
       left join company c on vacancy.company_id = c.company_id
where vacancy_ids_by_user.user_id = 4;

-- общий стаж по резюме
select cv_id,
       sum(
           case
             when date_to is null
               then (now()::date - date_from)
             else (date_to - date_from)
             end
         ) days
from curriculum_vitae_experience
group by cv_id;

-- отклики пользователя
select user_id, response_id, cv.cv_id, position, message
from vacancy_response
       left join curriculum_vitae cv on vacancy_response.cv_id = cv.cv_id
where user_id = 3;

-- приглашения пользователя
select inv.*, c.name, v.position
from invitation inv
       left join vacancy_response vr on inv.response_id = vr.response_id
       left join vacancy v on vr.vacancy_id = v.vacancy_id
       left join company c on v.company_id = c.company_id
       left join curriculum_vitae cv on vr.cv_id = cv.cv_id
       left join user_info u on cv.user_id = u.user_id
where u.user_id = 4;

-- история сообщений (без сопроводительного письма отклика и сообщений приглашений)
select message_id, u.last_name || ' ' || u.first_name || coalesce(' ' || u.patronymic, '') as sender, message
  .message
from message
       left join vacancy_response vr on message.response_id = vr.response_id
       left join user_info u on message.user_id = u.user_id
       left join vacancy v on vr.vacancy_id = v.vacancy_id
       left join company c on v.company_id = c.company_id
order by message.send_time ASC;
