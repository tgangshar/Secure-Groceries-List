FROM python:3

#Future needs to specify version numbers
RUN pip install --upgrade pip
RUN pip install Flask
RUN pip install requests
RUN pip install jsonlib-python3
RUN pip install pysqlite3

#To connect to backend
ARG api_ip
ENV TODO_API_IP=${api_ip}
# Sending Port
EXPOSE 80/tcp
#COPY todolist.python .
COPY NFrntTodolist.py .
#COPY BackTodolist.py .
#COPY todolist.db .
COPY templates/index.html templates/

#starting the Front end server
CMD python NFrntTodolist.py