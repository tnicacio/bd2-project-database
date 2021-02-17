create or replace function log_produto() 
returns trigger as 
$log_produto$

declare

begin

	if (new.usuario_id is not null)
		and (
				coalesce(old.preco, -1) <> coalesce(new.preco, -1)
			or	coalesce(old.qtd_estoque, -1) <> coalesce(new.qtd_estoque, -1)
			or	coalesce(old.descricao,'xpto') <> coalesce(new.descricao,'xpto')
			)
				then
	
		insert into log_movimentos (data,
									descricao,
									valor_anterior,
									valor_atual,
									qtde_anterior,
									qtde_atual,
									usuario_id)
							values (now(),
									new.descricao,
									old.preco,
									new.preco,
									old.qtd_estoque,
									new.qtd_estoque,
									new.usuario_id);
		return NEW;
	end if;
	
	return NULL; 
end;	
$log_produto$ language plpgsql;

create trigger trg_produto_before_update
before update on produto
for each row
execute procedure log_produto();
