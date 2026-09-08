create type public.tipo_conta as enum ('cliente', 'barbeiro');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nome text not null,
  tipo_conta public.tipo_conta not null,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

revoke all on table public.profiles from anon, authenticated;

grant select, insert, update
on table public.profiles
to authenticated;

create policy "Usuario pode ver o proprio perfil"
on public.profiles
for select
to authenticated
using ((select auth.uid()) = id);

create policy "Usuario pode criar o proprio perfil"
on public.profiles
for insert
to authenticated
with check ((select auth.uid()) = id);

create policy "Usuario pode atualizar o proprio perfil"
on public.profiles
for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

create or replace function public.prevent_tipo_conta_change()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if new.tipo_conta is distinct from old.tipo_conta then
    raise exception 'O tipo da conta não pode ser alterado';
  end if;

  return new;
end;
$$;

create trigger prevent_tipo_conta_change
before update of tipo_conta
on public.profiles
for each row
execute function public.prevent_tipo_conta_change();