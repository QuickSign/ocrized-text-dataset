FROM python:3-stretch

COPY . /work
WORKDIR /work
RUN ./setup.sh
RUN pip install poetry && poetry config settings.virtualenvs.create false
RUN poetry install --no-dev

CMD bash
