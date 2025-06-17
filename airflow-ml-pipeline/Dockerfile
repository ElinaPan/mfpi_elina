FROM apache/airflow:2.9.1-python3.10

# Переключаемся на airflow-пользователя
USER airflow

# Устанавливаем зависимости
COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt

# Копируем директории проекта
COPY dags/ /opt/airflow/dags/
COPY etl/ /opt/airflow/etl/
COPY results/ /opt/airflow/results/
COPY logs/ /opt/airflow/logs/



