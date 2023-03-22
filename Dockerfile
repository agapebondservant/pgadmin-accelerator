FROM dpage/pgadmin4
USER root
RUN pip3 install pyservicebinding
USER pgadmin
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/sh"]
