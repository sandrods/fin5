#!/bin/sh

# Script para backup dos bancos de dados

# Formata data para adicionar ao nome dos arquivos
t=`/bin/date +%Y%m%d`
tt=`/bin/date +%H%M%S`

db='fin5'

# Define o destino dos arquivos
DST="/Users/sandro/Dropbox/pg_bkp/fin"

# Cria o diretório do dia se ele não existir
if [ -d /Users/sandro/Dropbox/pg_bkp/fin ]; then
  cd $DST
else
  `mkdir $DST`
  cd $DST
fi

# Define permissoes de leitura e gravacao para o diretorio
# `chown -R postgres /opt/data/backup/`
# `chown -R postgres /opt/data/backup/$t`
# `chmod 0777 /opt/data/backup/$t`

file="$t"-"$tt"-"$db.bkp"

pg_dump $db -Fc -f $file

echo "BackUp to $DST/$file"

ln -f -s $file last.bkp


# restore
# pg_restore db/bkp/fin/last.bkp -d fin5 -c

# restore --force
# rake db:drop
# rake db:create
# pg_restore db/bkp/fin/last.bkp -d fin_development
