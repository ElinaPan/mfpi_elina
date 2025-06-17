import logging
from sklearn.linear_model import LogisticRegression

# Настройка логгера
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

def train_model(X_train, y_train):
    try:
        logging.info("Начало обучения модели LogisticRegression")

        model = LogisticRegression(max_iter=1000)
        model.fit(X_train, y_train)

        logging.info("Модель успешно обучена")
        return model

    except Exception as e:
        logging.error(f"Ошибка при обучении модели: {e}", exc_info=True)
        raise

if __name__ == "__main__":
    train_model()