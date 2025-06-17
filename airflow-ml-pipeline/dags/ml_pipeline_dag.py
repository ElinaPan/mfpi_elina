import sys
import os
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

# Добавим путь к папке etl
ETL_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'etl'))
if ETL_PATH not in sys.path:
    sys.path.insert(0, ETL_PATH)

from load import load_data
from preprocess import preprocess_data
from train import train_model
from evaluate import evaluate_model
from save import save_to_local

# Убедимся, что папки существуют
os.makedirs("logs", exist_ok=True)
os.makedirs("/opt/airflow/results", exist_ok=True)
os.makedirs("/opt/airflow/final_model", exist_ok=True)

# Общие аргументы DAG
default_args = {
    "owner": "elina",
    "retries": 2,
    "retry_delay": timedelta(seconds=30),
    "execution_timeout": timedelta(minutes=5),
}

with DAG(
    dag_id="breast_cancer_ml_pipeline_DAG",
    start_date=datetime(2025, 6, 13),
    schedule_interval=timedelta(days=1),
    catchup=False,
    tags=["ml", "breast_cancer"],
    description="ML pipeline for breast cancer classification with logging and robustness",
    default_args=default_args,
) as dag:

    def load_data_wrapper():
        df = load_data()
        df.to_csv("/opt/airflow/results/raw_data.csv", index=False)

    def preprocess_data_wrapper():
        import pickle
        X_train, X_test, y_train, y_test = preprocess_data()
        with open("/opt/airflow/results/preprocessed.pkl", "wb") as f:
            pickle.dump((X_train, X_test, y_train, y_test), f)

    def train_model_wrapper():
        import pickle
        with open("/opt/airflow/results/preprocessed.pkl", "rb") as f:
            X_train, X_test, y_train, y_test = pickle.load(f)
        model = train_model(X_train, y_train)
        with open("/opt/airflow/results/model.pkl", "wb") as f:
            pickle.dump(model, f)

    def evaluate_model_wrapper():
        import pickle
        import json
        with open("/opt/airflow/results/preprocessed.pkl", "rb") as f:
            X_train, X_test, y_train, y_test = pickle.load(f)
        with open("/opt/airflow/results/model.pkl", "rb") as f:
            model = pickle.load(f)
        metrics = evaluate_model(model, X_test, y_test)
        with open("/opt/airflow/results/metrics.json", "w") as f:
            json.dump(metrics, f, indent=4)

    def save_model_wrapper():
        save_to_local()

    t1 = PythonOperator(
        task_id="load_data",
        python_callable=load_data_wrapper
    )

    t2 = PythonOperator(
        task_id="preprocess_data",
        python_callable=preprocess_data_wrapper
    )

    t3 = PythonOperator(
        task_id="train_model",
        python_callable=train_model_wrapper
    )

    t4 = PythonOperator(
        task_id="evaluate_model",
        python_callable=evaluate_model_wrapper
    )

    t5 = PythonOperator(
        task_id="save_model",
        python_callable=save_model_wrapper
    )

    t1 >> t2 >> t3 >> t4 >> t5
