create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if
    new.raw_user_meta_data ? 'nome'
    and new.raw_user_meta_data ? 'tipo_conta'
  then
    insert into public.profiles (
      id,
      nome,
      tipo_conta
    )
    values (
      new.id,
      new.raw_user_meta_data ->> 'nome',
      (new.raw_user_meta_data ->> 'tipo_conta')::public.tipo_conta
    )
    on conflict (id) do nothing;
  end if;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row
execute function public.handle_new_user();
