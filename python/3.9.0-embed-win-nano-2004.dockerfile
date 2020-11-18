FROM mcr.microsoft.com/powershell:nanoserver-2004

SHELL [ "pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';" ]

ENV PY_VER 3.9.0
ENV PY_PTH 39
RUN $url = ('https://www.python.org/ftp/python/{0}/python-{1}-embed-amd64.zip' -f $Env:PY_VER, $Env:PY_VER); \
    Write-host "downloading: $url"; \
    New-Item -ItemType Directory /installer > $null ; \
    Invoke-WebRequest -Uri "$url" -outfile /installer/Python.zip -verbose; \
    Expand-Archive /installer/Python.zip -DestinationPath /Python; \
    Move-Item "/Python/python${Env:PY_PTH}._pth" "/Python/python${Env:PY_PTH}._pth.save"; \
    setx PATH "$Env:Path`C:\Python`;C:\Python\Scripts`;"

RUN python --version

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 20.2.4
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/fa7dc83944936bf09a0e4cb5d5ec852c0d256599/get-pip.py
ENV PYTHON_GET_PIP_SHA256 6e0bb0a2c2533361d7f297ed547237caf1b7507f197835974c0dd7eba998c53c

RUN Write-Host ('Downloading get-pip.py ({0}) ...' -f $env:PYTHON_GET_PIP_URL); \
    Invoke-WebRequest -Uri $env:PYTHON_GET_PIP_URL -OutFile 'get-pip.py'; \
    Write-Host ('Verifying sha256 ({0}) ...' -f $env:PYTHON_GET_PIP_SHA256); \
    if ((Get-FileHash 'get-pip.py' -Algorithm sha256).Hash -ne $env:PYTHON_GET_PIP_SHA256) { \
        Write-Host 'FAILED!'; \
        exit 1; \
    }; \
    Write-Host ('Installing pip=={0} ...' -f $env:PYTHON_PIP_VERSION); \
    python get-pip.py \
        --disable-pip-version-check \
        --no-cache-dir \
        ('pip=={0}' -f $env:PYTHON_PIP_VERSION) \
    ; \
    Remove-Item get-pip.py -Force; \
    Write-Host 'Verifying pip install ...'; \
    pip --version; \
    Write-Host 'Complete.'

CMD [ "python.exe" ]
