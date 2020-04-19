# docker build --build-arg node_version=v12.16.2 -t nodejs-win32:latest .

FROM mcr.microsoft.com/windows/servercore:ltsc2019

ARG node_version
ENV NODE_VERSION $node_version

ADD https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-win-x64.zip ./node.zip

RUN powershell.exe Install-PackageProvider -Name NuGet -Force; \
    Install-Module 7Zip4PowerShell -Force -Verbose
RUN powershell.exe Expand-7Zip -ArchiveFileName .\node.zip -TargetPath .

FROM mcr.microsoft.com/windows/nanoserver:1809

USER ContainerAdministrator

ARG node_version
ENV NODE_VERSION $node_version

COPY --from=0 C:\\node-${NODE_VERSION}-win-x64 C:\\node
RUN setx.exe /m PATH %PATH%;C:\\node && \
    reg.exe ADD HKLM\SYSTEM\CurrentControlSet\Control\FileSystem /v LongPathsEnabled /t REG_DWORD /d 1 /f

USER ContainerUser

RUN node --version

CMD ["node"]
