-- попытка авторизации
select true as success
from users
where login = 'user1'
  and password = crypt('very_strong_pass', password)
  and active is true;

-- все активные пользователи с информацией о городе
select u.user_id, u.login, u.last_name, u.first_name, u.patronymic, c.name
from users u
       left join cities c on c.city_id = u.city_id
where u.active is true;

-- все активные компании
select company_id, companies.name, url, cities.name
from companies
       left join cities on companies.city_id = cities.city_id
where companies.active is true;


-- список hr компании
select companies_hr.company_id, companies_hr.user_id, name as company_name, last_name, first_name, patronymic
from companies_hr
       left join companies comp on companies_hr.company_id = comp.company_id
       left join users on companies_hr.user_id = users.user_id
where comp.company_id = 1;

-- активные вакансии компаний
select vacancies.vacancy_id,
       vacancies.position,
       comp.name,
       cities.name,
       vacancies.description,
       vacancies.salary_from,
       vacancies.salary_to,
       vacancies.experience,
       vacancies.posted,
       vacancies.company_id,
       cities.city_id
from vacancies
       left join companies comp on vacancies.company_id = comp.company_id
       left join cities on comp.city_id = cities.city_id
where expired > now();

-- необходимые скилы по вакансии
select *
from vacancies_skills
       left join skills s on vacancies_skills.skill_id = s.skill_id
where vacancy_id = 3;

-- вакансии для пользователя по скиллам
with user_skills as (select distinct skill_id, user_id
                     from curriculum_vitae_skills as cv_skills
                            left join curriculum_vitae cv on cv_skills.cv_id = cv.cv_id)
select vacancies.vacancy_id, vacancies.position, c.name
from vacancies
       left join vacancies_skills vs on vacancies.vacancy_id = vs.vacancy_id
       left join companies c on vacancies.company_id = c.company_id
       left join user_skills on vs.skill_id = user_skills.skill_id
where user_id = 4
group by vacancies.vacancy_id, c.name;


with user_skills as (select distinct skill_id, user_id
                     from curriculum_vitae_skills as cv_skills
                            left join curriculum_vitae cv on cv_skills.cv_id = cv.cv_id),
     vacancy_ids_by_user as (select distinct vacancy_id, user_id
                             from vacancies_skills
                                    left join user_skills on vacancies_skills.skill_id = user_skills.skill_id
     )
select *
from vacancy_ids_by_user
       left join vacancies on vacancy_ids_by_user.vacancy_id = vacancies.vacancy_id
       left join companies c on vacancies.company_id = c.company_id
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
       left join vacancies v on vr.vacancy_id = v.vacancy_id
       left join companies c on v.company_id = c.company_id
       left join curriculum_vitae cv on vr.cv_id = cv.cv_id
       left join users u on cv.user_id = u.user_id
where u.user_id = 4;

-- история сообщений (без сопроводительного письма отклика и сообщений приглашений)
select message_id, u.last_name || ' ' || u.first_name || coalesce(u.patronymic || ' ', '') as sender, messages.message
from messages
       left join vacancy_response vr on messages.response_id = vr.response_id
       left join users u on messages.user_id = u.user_id
       left join vacancies v on vr.vacancy_id = v.vacancy_id
       left join companies c on v.company_id = c.company_id
order by messages.send_time ASC;

-- авторизация, см. auth в 04_functions.sql
select auth('user2', 'very_strong_pass', '128.0.0.2');

