truncate table vacancy_skills cascade;
truncate table message cascade;
truncate table invitation cascade;
truncate table vacancy_response cascade;
truncate table vacancy cascade;
truncate table cv_skills cascade;
truncate table cv_experience cascade;
truncate table cv cascade;
truncate table skill cascade;
truncate table company cascade;
truncate table auth_info cascade;
truncate table user_info cascade;
truncate table city cascade;

alter sequence if exists user_info_user_id_seq restart with 1;
alter sequence if exists company_company_id_seq restart with 1;
alter sequence if exists vacancy_vacancy_id_seq restart with 1;
alter sequence if exists skill_skill_id_seq restart with 1;
alter sequence if exists cv_cv_id_seq restart with 1;
alter sequence if exists cv_experience_cv_experience_id_seq restart with 1;
alter sequence if exists vacancy_response_response_id_seq restart with 1;
alter sequence if exists invitation_invitation_id_seq restart with 1;
alter sequence if exists message_message_id_seq restart with 1;

insert into city (city_id, name)
values (1, 'Москва'),
       (2, 'Санкт-Петербург');

insert into user_info (last_name, first_name, birth_date, city_id, registered_time)
values ('Антонов', 'Андрей', '1990-10-10', 1, now()),
       ('Иванова', 'Антонина', '1992-01-30', 2, now()),
       ('Попова', 'Алевтина', '1993-11-28', 2, now()),
       ('Михайлов', 'Григорий', '1982-06-12', 2, now()),
       ('Сарычев', 'Инокентий', '1987-02-04', 2, now());

insert into auth_info (user_id, login, password, active)
values (1, 'user1', 'sfsafafdgdlfkgd', true),
       (2, 'user2', 'sfsafafdgdlfkgd', true),
       (3, 'user3', 'sfsafafdgdlfkgd', true),
       (4, 'user4', 'sfsafafdgdlfkgd', true),
       (5, 'user5', 'sfsafafdgdlfkgd', true);


insert into company (name, description, city_id, mcp_user_info_id, active, registered_time)
values ('ООО ВЕКТОР', 'Мы специализируемся на всех векторах развития', 1, 5, true, now()),
       ('ООО МАТРИЦА', 'Следуй за белым кроликом! Мы больше чем вектор', 1, 4, true, now()),
       ('ООО ТЕНЗОР', 'Мы специализируемся на суровой алгебре', 2, 1, true, now());

insert into company_hr (company_id, user_info_id)
values (1, 1),
       (2, 4),
       (3, 5);

insert into vacancy (company_id, position, description, salary_from, salary_to, experience, city_id, expired_time, posted_time)
values (1, 'Скаляр', 'Ищем скаляры для наших векторов!', 10000, null, 'none', 1, '2018-12-31', now()),
       (1, 'Скаляр', 'Ищем скаляры для наших векторов!', 15000, null, 'none', 2, '2018-12-31', now()),
       (2, 'Единица', 'Срочно ищется единичная матрица, без которой нам не стать полем', null, 400000, 'more than 6', 2,
        '2018-12-31', now());

insert into skill (title)
values ('квадратная матрица'),
       ('диагональная матрица'),
       ('единичная матрица'),
       ('скаляр');

insert into vacancy_skills (vacancy_id, skill_id)
values (1, 4),
       (3, 1),
       (3, 2),
       (3, 3);

insert into cv (user_info_id, position, salary_from, salary_to, published, moderated, created_time, updated_time, visibility)
values (3, 'Скаляр', 10000, null, true, true, now(), now(), true),
       (3, 'Скаляр', 15000, null, true, true, now(), now(), true),
       (4, 'Матрица', 35000, null, true, true, now(), now(), true);

insert into cv_skills (cv_id, skill_id)
values (1, 3),
       (2, 3),
       (3, 1),
       (3, 2),
       (3, 3);

insert into cv_experience (cv_id, company_id, company_name, date_from, date_to, description)
values (1, 1, null, '1970-01-01', null, 'Сотрудничал с векторами с начала unix эпохи!'),
       (1, null, 'ООО СКАЛЯР', '1969-01-01', '1969-12-31', 'А до этого работал с другими скалярами'),
       (3, 2, null, '2010-10-10', '2011-10-11', 'Работал в группе D(4,R)');

insert into vacancy_response (vacancy_id, cv_id, message, send_time)
values (2, 1, 'Хочу в новый город!', now()),
       (3, 3, 'Смогу быть единицей', now());

insert into invitation (vacancy_response_id, interview_time, message, send_time)
values (2, '2018-12-30 14:00:00', 'Ждем Вас!', now());


insert into message(user_info_id, vacancy_response_id, message, send_time)
values (5, 1, 'Простите, Вы необходимы в Питере', now()),
       (3, 1, 'Жаль', now());