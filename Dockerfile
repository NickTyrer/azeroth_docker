FROM nicktyrer/azeroth_base:latest
COPY setup.sh /
COPY start.sh /
COPY db_setup.sh /
RUN chmod +x setup.sh start.sh db_setup.sh
RUN /setup.sh
CMD ["/start.sh"]
