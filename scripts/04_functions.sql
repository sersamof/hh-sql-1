
-- функция авторизации
-- не думаю, что эту логику стоит хранить в базе, но для полноты демо пусть будет :)
drop function if exists auth;
create or replace function auth(auth_login varchar(50), auth_pass text, auth_ip text) returns boolean
  volatile
  language plpgsql
as
$$
DECLARE
  success        boolean;
  ip_banned      boolean;
  login_attempts int;
  ip_attempts    int;
BEGIN
  delete from flood where last_attempt < now() - interval '1 hour';
  select true from banned where ip = auth_ip and banned_until < now() into ip_banned;

  if ip_banned = true then
    return false;
  end if;


  select true as success
  from auth_info
  where login = auth_login
    and password = crypt(auth_pass, password)
    and active is true into success;

  if success is true then
    delete from flood where login = auth_login;
  else
    insert into flood (ip, attempts, last_attempt)
    values (auth_ip, 1, now())
    on conflict(
       ip)
       do update set attempts = flood.attempts + 1, last_attempt = now()
       returning attempts into ip_attempts;

    insert into flood (login, attempts, last_attempt)
    values (auth_login, 1, now())
    on conflict(
       login)
       do update set attempts = flood.attempts + 1, last_attempt = now()
       returning attempts into login_attempts;

    if ip_attempts >= 5 or login_attempts >= 5 then
      insert into banned (ip, banned_until)
      values (auth_ip, now() + interval '3 hour')
      on conflict(
         ip)
         do update set banned_until = EXCLUDED.banned_until;
    end if;

    if login_attempts >= 5 then
      update auth_info set active = false where login = auth_login;
    end if;
  end if;

  return success;
END
$$;