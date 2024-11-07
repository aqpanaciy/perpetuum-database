FROM mcr.microsoft.com/mssql/server:2022-latest

USER root
RUN apt update
RUN apt install unzip

# Create a config directory
RUN mkdir -p /usr/config
WORKDIR /usr/config

# Bundle config source
COPY *.sh *.sql perpetuumsa+data.dacpac /usr/config

# Get SqlPackage for Linux
RUN wget https://aka.ms/sqlpackage-linux -O /usr/config/sqlpackage-linux.zip
RUN unzip /usr/config/sqlpackage-linux.zip -d /usr/config/
RUN rm -f /usr/config/sqlpackage-linux.zip

# Grant permissions for to our scripts to be executable
RUN chmod +x /usr/config/entrypoint.sh
RUN chmod +x /usr/config/configure-db.sh
RUN chmod +x /usr/config/sqlpackage

ENTRYPOINT ["./entrypoint.sh"]
