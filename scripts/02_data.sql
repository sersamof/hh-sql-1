truncate table vacancies_skills cascade;
truncate table messages cascade;
truncate table invitation cascade;
truncate table vacancy_response cascade;
truncate table vacancies cascade;
truncate table curriculum_vitae_skills cascade;
truncate table curriculum_vitae_experience cascade;
truncate table curriculum_vitae cascade;
truncate table skills cascade;
truncate table companies cascade;
truncate table users cascade;
truncate table cities cascade;
truncate table flood cascade;
truncate table banned cascade;

alter sequence cities_city_id_seq restart with 1;
alter sequence users_user_id_seq restart with 1;
alter sequence flood_flood_id_seq restart with 1;
alter sequence companies_company_id_seq restart with 1;
alter sequence vacancies_vacancy_id_seq restart with 1;
alter sequence skills_skill_id_seq restart with 1;
alter sequence curriculum_vitae_cv_id_seq restart with 1;
alter sequence curriculum_vitae_experience_cv_experience_id_seq restart with 1;
alter sequence vacancy_response_response_id_seq restart with 1;
alter sequence invitation_invitation_id_seq restart with 1;
alter sequence messages_message_id_seq restart with 1;

-- для crypt и gen_salt. хотя скорее солить и хэшировать будет отдельный сервис аутентификации перед передачей в бд
create extension if not exists pgcrypto;

insert into cities (name)
values ('Москва'),
       ('Санкт-Петербург');

insert into users (login, last_name, first_name, birth_date, city_id, password)
values ('user1', 'Антонов', 'Андрей', '1990-10-10', 1, crypt('very_strong_pass', gen_salt('bf'))),
       ('user2', 'Иванова', 'Антонина', '1992-01-30', 2, crypt('very_strong_pass', gen_salt('bf'))),
       ('user3', 'Попова', 'Алевтина', '1993-11-28', 2, crypt('very_strong_pass', gen_salt('bf'))),
       ('user4', 'Михайлов', 'Григорий', '1982-06-12', 2, crypt('very_strong_pass', gen_salt('bf'))),
       ('user5', 'Сарычев', 'Инокентий', '1987-02-04', 2, crypt('very_strong_pass', gen_salt('bf')));


insert into companies (name, description, city_id, admin)
values ('ООО ВЕКТОР', 'Мы специализируемся на всех векторах развития', 1, 1),
       ('ООО МАТРИЦА', 'Следуй за белым кроликом! Мы больше чем вектор', 1, 1),
       ('ООО ТЕНЗОР', 'Мы специализируемся на суровой алгебре', 2, 1);

insert into companies_hr (company_id, user_id)
values (1, 5),
       (2, 4),
       (3, 5);

insert into vacancies (company_id, position, description, salary_from, salary_to, experience, city_id, expired)
values (1, 'Скаляр', 'Ищем скаляры для наших векторов!', 10000, null, 'none', 1, '2018-12-31'),
       (1, 'Скаляр', 'Ищем скаляры для наших векторов!', 15000, null, 'none', 2, '2018-12-31'),
       (2, 'Единица', 'Срочно ищется единичная матрица, без которой нам не стать полем', null, 400000, 'more than 6', 2,
        '2018-12-31');

insert into skills (title)
values ('квадратная матрица'),
       ('диагональная матрица'),
       ('единичная матрица'),
       ('скаляр');

insert into vacancies_skills (vacancy_id, skill_id)
values (1, 4),
       (3, 1),
       (3, 2),
       (3, 3);

insert into curriculum_vitae (user_id, position, salary_from, salary_to)
values (3, 'Скаляр', 10000, null),
       (3, 'Скаляр', 15000, null),
       (4, 'Матрица', 35000, null);

insert into curriculum_vitae_skills (cv_id, skill_id)
values (1, 3),
       (2, 3),
       (3, 1),
       (3, 2),
       (3, 3);

insert into curriculum_vitae_experience (cv_id, company_id, company_name, date_from, date_to, description)
values (1, 1, null, '1970-01-01', null, 'Сотрудничал с векторами с начала unix эпохи!'),
       (1, null, 'ООО СКАЛЯР', '1969-01-01', '1969-12-31', 'А до этого работал с другими скалярами'),
       (3, 2, null, '2010-10-10', '2011-10-11', 'Работал в группе D(4,R)');

insert into vacancy_response (vacancy_id, cv_id, message)
values (2, 1, 'Хочу в новый город!'),
       (3, 3, 'Смогу быть единицей');

insert into invitation (response_id, interview_datetime, contact_person, contact_phone, address, message)
values (2, '2018-12-30 14:00:00', 'Андреев Алексей Иванович', '79998887766', 'проспект Ленниа, 42', 'Ждем Вас!');


insert into messages(user_id, response_id, message)
values (5, 1, 'Простите, Вы необходимы в Питере'),
       (3, 1, 'Жаль');