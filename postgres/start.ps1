$ErrorActionPreference = 'Stop';

if(-not (Test-Path -path "${Env:PGDATA}/*" ) )
{
    initdb --encoding="UTF8";
    Add-Content -Path "${Env:PGDATA}/postgresql.conf" ""
    Add-Content -Path "${Env:PGDATA}/postgresql.conf" "listen_addresses = '*'"
    Add-Content -Path "${Env:PGDATA}/pg_hba.conf" ""
    Add-Content -Path "${Env:PGDATA}/pg_hba.conf" "host  all  all  0.0.0.0/0  trust"
    Add-Content -Path "${Env:PGDATA}/pg_hba.conf" "host  all  all  ::0/0      trust"
}

pg_ctl -D "${Env:PGDATA}" start -l pg.log
if( -not $? )
{
    exit $LASTEXITCODE
}

while( $true )
{
    Start-Sleep 3
    pg_ctl -D "${Env:PGDATA}" status > $NUL
    if( -not $? )
    {
        exit $LASTEXITCODE
    }
}
