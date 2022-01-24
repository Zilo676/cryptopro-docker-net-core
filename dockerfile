FROM ubuntu:20.04
WORKDIR /

RUN apt-get update \ 
  && apt-get install -y wget gpg apt-transport-https

# установка рантайма для ubuntu 20.04
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
  && dpkg -i packages-microsoft-prod.deb \
  && rm packages-microsoft-prod.deb

RUN apt-get update \
  && apt-get install -y apt-transport-https \
  && apt-get update  \
  && apt-get install -y --allow-downgrades dotnet-sdk-3.1=3.1.300-1

ENV DOTNET_MULTILEVEL_LOOKUP=0

# установка пакетов криптопро
COPY ./linux-amd64_deb.tgz /linux-amd64_deb.tgz
RUN tar -xf /linux-amd64_deb.tgz
RUN cd /linux-amd64_deb \
  && chmod +x ./install.sh \
  && ./install.sh

COPY ./package-linux-debug/ /package-linux-debug
COPY ./runtime-debug-linux/ /runtime-debug-linux

RUN apt-get install git --no-install-recommends -y \
  && git config --global http.sslVerify false \
  && git config --global http.postBuffer 1048576000

COPY ./NuGet.Config /root/.nuget/NuGet/NuGet.Config

RUN git clone https://github.com/CryptoProLLC/NetStandard.Library
RUN mkdir -p ~/.nuget/packages/netstandard.library
RUN cp -r ./NetStandard.Library/nugetReady/netstandard.library ~/.nuget/packages/

WORKDIR /app

RUN git clone https://github.com/CryptoPro/DotnetCoreSampleProject .
COPY ./DotnetSampleProject.csproj ./DotnetSampleProject.csproj
COPY ./NuGet.Config ./NuGet.Config

RUN dotnet restore "DotnetSampleProject.csproj" --configfile ./NuGet.Config
RUN dotnet build "DotnetSampleProject.csproj"

CMD ["dotnet", "run"]
