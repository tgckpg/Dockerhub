FROM penguinade/python:win-nano-3.9.0-embed
SHELL [ "pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';" ]

RUN Invoke-WebRequest -UseBasicParsing -Uri "https://get.enterprisedb.com/postgresql/postgresql-12.5-1-windows-x64-binaries.zip" -OutFile 'PostgreSQL.zip' ; \
    Expand-Archive PostgreSQL.zip -dest 'C:\\' ; \
    Rename-Item "C:\\pgsql" 'C:\\PostgreSQL' ; \
    Remove-Item PostgreSQL.zip -Force; \
    setx PATH "C:\PostgreSQL\bin`;$Env:PATH"; \
    setx PGDATA "C:\PostgreSQL\data";

RUN mkdir /PostgreSQL/data > $NULL; postgres -V
COPY start.ps1 /run/start.ps1

EXPOSE 5432
ENTRYPOINT [ "pwsh", "-F", "/run/start.ps1" ]
