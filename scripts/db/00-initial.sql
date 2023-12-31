create schema if not exists schema;

create sequence if not exists schema.seq_users;
create sequence if not exists schema.seq_comments;

create table if not exists schema.users
(
  id int not null default nextval('schema.seq_users'::regclass),
  name varchar not null,
  email varchar not null,
  password varchar not null,
  is_admin boolean not null default false,
  constraint "PK_users" primary key (id),
  constraint "UQ_users_email" unique (email),
  constraint "CHK_users_email" check (email like '%@%')
);

create table if not exists schema.comments
(
  id int not null default nextval('schema.seq_comments'::regclass),
  id_user int not null,
  txt varchar not null,
  constraint "PK_comments" primary key (id)
);


create or replace function schema.user_get(_id integer) 
  returns json as
$BODY$
declare
  _ret json;
begin
  if _id = 0 then
    select array_to_json(array(
      select row_to_json(r)
      from (
        select u.id, u.name, u.email
        from schema.users u
      ) r
    )) into _ret;
  else
    select row_to_json(r) into _ret
    from (
      select u.id, u.name, u.email
      from schema.users u
      where id = _id
    ) r;
  end if;

  return _ret;

  exception when others then

  return json_build_object('error', SQLERRM);
end
$BODY$
language plpgsql volatile cost 100;


create or replace function schema.user_ins(_params json)
  returns json as
$BODY$
declare
  _newid integer;
begin
  _newid = 0;

  insert into schema.users (name, email)
  select name, email
  from json_populate_record(null::schema.users, _params)
  returning id into _newid;

  return json_build_object('id', _newid);

  exception when others then

  return json_build_object('error', SQLERRM);
end
$BODY$
language plpgsql volatile cost 100;


create or replace function schema.user_upd(_id integer, _params json)
  returns json as
$BODY$
begin
  update schema.users set
    name = _params->>'name',
    email = _params->>'email'
  where id = _id;

  return json_build_object('id', _id);

  exception when others then

  return json_build_object('error', SQLERRM);
end
$BODY$
language plpgsql volatile cost 100;


create or replace function schema.user_del(_id integer)
  returns json as
$BODY$
begin
  delete from schema.users where id = _id;

  return json_build_object('id', _id);

  exception when others then

  raise notice 'Illegal operation: %', SQLERRM;

  return json_build_object('error', SQLERRM);
end
$BODY$
language plpgsql volatile cost 100;


-- Реализовать самостоятельно:

-- просмотр комментария по id или всех, если id = 0
--create or replace function schema.comment_get(_id integer);

-- редактирование текста комментария с указанным id. Авторство комментария менять нельзя.
--create or replace function schema.comment_upd(_id integer, _params json);

-- удаление комментария с указанным id
--create or replace function schema.comment_del(_id integer);

-- добавление комментария за авторством пользователя _id_user
--create or replace function schema.user_comment_ins(_id_user integer, _params json);
