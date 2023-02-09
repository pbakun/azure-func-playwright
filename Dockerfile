
FROM mcr.microsoft.com/playwright/dotnet:v1.27.0-focal AS playwright
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS installer-env

# Build requires 3.1 SDK
COPY --from=mcr.microsoft.com/dotnet/core/sdk:3.1 /usr/share/dotnet /usr/share/dotnet

COPY . /src/dotnet-function-app
RUN cd /src/dotnet-function-app && \
    mkdir -p /home/site/wwwroot && \
    dotnet publish *.csproj --output /home/site/wwwroot

# To enable ssh & remote debugging on app service change the base image to the one below
# FROM mcr.microsoft.com/azure-functions/dotnet:4-appservice
FROM mcr.microsoft.com/azure-functions/dotnet:4
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true

RUN apt-get update && apt-get install -y --no-install-recommends \
                   libglib2.0-0\
                   libnss3\
                   libnspr4\
                   libatk1.0-0\
                   libatk-bridge2.0-0\
                   libcups2\
                   libdrm2\
                   libdbus-1-3\
                   libatspi2.0-0\
                   libxcomposite1\
                   libxdamage1\
                   libxext6\
                   libxfixes3\
                   libxrandr2\
                   libgbm1\
                   libxkbcommon0\
                   libpango-1.0-0\
                   libcairo2\
                   libasound2\
                   libwayland-client0

ENV PLAYWRIGHT_BROWSERS_PATH=$HOME/pw-browsers
COPY --from=playwright ["/ms-playwright/chromium-1028", "/home/pw-browsers/chromium-1028" ]
COPY --from=installer-env ["/home/site/wwwroot", "/home/site/wwwroot"]