import logging
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, classification_report

# Настройка логгера
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

def evaluate_model(model, X_test, y_test):
    try:
        logging.info("Оценка качества модели на тестовой выборке")

        predictions = model.predict(X_test)

        accuracy = accuracy_score(y_test, predictions)
        precision = precision_score(y_test, predictions)
        recall = recall_score(y_test, predictions)
        f1 = f1_score(y_test, predictions)
        report = classification_report(y_test, predictions, output_dict=True)

        logging.info(f"Accuracy: {accuracy:.4f}")
        logging.info(f"Precision: {precision:.4f}")
        logging.info(f"Recall: {recall:.4f}")
        logging.info(f"F1 Score: {f1:.4f}")

        return {
            "accuracy": accuracy,
            "precision": precision,
            "recall": recall,
            "f1_score": f1,
            "report": report
        }

    except Exception as e:
        logging.error(f"Ошибка при оценке модели: {e}", exc_info=True)
        raise

if __name__ == "__main__":
    evaluate_model()