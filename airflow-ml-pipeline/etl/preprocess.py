import logging
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from load import load_data

# Настройка логгера
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

def preprocess_data(test_size=0.2, random_state=42):
    try:
        logging.info("Начало предобработки данных")

        df = load_data()
        X = df.drop("target", axis=1)
        y = df["target"]

        logging.info("Применение стандартизации признаков")
        scaler = StandardScaler()
        X_scaled = scaler.fit_transform(X)

        logging.info("Разбиение на обучающую и тестовую выборки")
        X_train, X_test, y_train, y_test = train_test_split(
            X_scaled, y, test_size=test_size, random_state=random_state
        )

        logging.info("Предобработка завершена успешно")
        return X_train, X_test, y_train, y_test

    except Exception as e:
        logging.error(f"Ошибка при предобработке данных: {e}", exc_info=True)
        raise

if __name__ == "__main__":
    preprocess_data()
