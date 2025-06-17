import pandas as pd
from sklearn.datasets import load_breast_cancer
import logging

# Настройка логгера
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

def load_data():
    try:
        logging.info("Загрузка встроенного датасета breast cancer")
        data = load_breast_cancer(as_frame=True)
        df = data.frame

        logging.info("Размерность данных: %s", df.shape)
        logging.info("Типы данных:\n%s", df.dtypes)
        logging.info("Пропущенные значения:\n%s", df.isnull().sum())
        logging.info("Распределение классов:\n%s", df['target'].value_counts())

        return df

    except Exception as e:
        logging.error(f"Ошибка при загрузке данных: {e}", exc_info=True)
        raise

if __name__ == "__main__":
    load_data()
