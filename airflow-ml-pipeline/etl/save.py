import os
import json
import pickle
import logging

# Настройка логгера
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

def save_to_local():
    try:
        logging.info("Начало сохранения модели и метрик в финальную папку")

        # Пути к файлам
        model_input_path = "results/model.pkl"
        metrics_input_path = "results/metrics.json"
        model_output_path = "final_model/model.pkl"
        metrics_output_path = "final_model/metrics.json"

        # Проверка наличия входных файлов
        if not os.path.exists(model_input_path):
            raise FileNotFoundError(f"Файл модели не найден: {model_input_path}")
        if not os.path.exists(metrics_input_path):
            raise FileNotFoundError(f"Файл метрик не найден: {metrics_input_path}")

        # Создание целевой директории
        os.makedirs(os.path.dirname(model_output_path), exist_ok=True)

        # Копирование модели
        with open(model_input_path, "rb") as f_in, open(model_output_path, "wb") as f_out:
            model = pickle.load(f_in)
            pickle.dump(model, f_out)
        logging.info(f"Модель сохранена в {model_output_path}")

        # Копирование метрик
        with open(metrics_input_path, "r") as f_in, open(metrics_output_path, "w") as f_out:
            metrics = json.load(f_in)
            json.dump(metrics, f_out, indent=4)
        logging.info(f"Метрики сохранены в {metrics_output_path}")

    except Exception as e:
        logging.error(f"Ошибка при финальном сохранении: {e}", exc_info=True)
        raise

if __name__ == "__main__":
    save_to_local()
