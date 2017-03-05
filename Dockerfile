FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive
ENV JULIA_LOAD_PATH="/vagrant/"
ENV PATH "${PATH}:${GUROBI_HOME}/bin"

# Bundle app source
ADD . /src
RUN rm -rf /src/*.log # precaution - mainly for dev
RUN apt-get update --yes --force-yes
RUN sudo apt-get install --yes --force-yes software-properties-common supervisor
RUN cd /src/build/ && bash ubuntu-install.sh
RUN ln -s /src/build/supervisor-app.conf /etc/supervisor/conf.d/
RUN rm -f /src/scheduler.log
RUN touch /src/scheduler.log

# Expose - note that load balancer terminates SSL
EXPOSE 80

# RUN
CMD ["supervisord", "-n"]

