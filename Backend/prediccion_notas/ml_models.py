import os
import pandas as pd
import joblib
from django.conf import settings

# Ruta a la carpeta de modelos
MODEL_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'modelos')

# Cargar modelos y encoder
def load_models():
    try:
        # Cargar clasificador (predicción aprobado/reprobado)
        classifier = joblib.load(os.path.join(MODEL_DIR, 'modelo_clasificador.pkl'))
        
        # Cargar regresor (predicción nota final)
        regressor = joblib.load(os.path.join(MODEL_DIR, 'modelo_regresor.pkl'))
        
        # Cargar LabelEncoder
        label_encoder = joblib.load(os.path.join(MODEL_DIR, 'label_encoder.pkl'))
        
        # Opción 1: Cargar promedios desde un archivo
        try:
            # Si has guardado los promedios en un archivo
            promedios = joblib.load(os.path.join(MODEL_DIR, 'promedios.pkl'))
        except:
            # Opción 2: Usar valores predefinidos como respaldo
            promedios = {
                'ser': 70.0,
                'saber': 65.0,
                'hacer': 68.0,
                'decidir': 72.0
            }
        
        return {
            'classifier': classifier,
            'regressor': regressor,
            'label_encoder': label_encoder,
            'promedios': promedios
        }
    except Exception as e:
        print(f"Error cargando modelos: {e}")
        return None

# Función para predecir
def predecir_riesgo_y_nota(nota_parcial):
    models = load_models()
    if not models:
        return None, None
    
    classifier = models['classifier']
    regressor = models['regressor']
    label_encoder = models['label_encoder']
    promedios = models['promedios']
    
    # Rellenar faltantes con promedios
    entrada = {
        'ser': nota_parcial.get('ser', promedios['ser']),
        'saber': nota_parcial.get('saber', promedios['saber']),
        'hacer': nota_parcial.get('hacer', promedios['hacer']),
        'decidir': nota_parcial.get('decidir', promedios['decidir']),
    }
    entrada_df = pd.DataFrame([entrada])

    # Predicción de estado (clasificación)
    pred_estado = classifier.predict(entrada_df)[0]
    estado_resultado = label_encoder.inverse_transform([pred_estado])[0]

    # Predicción de nota final (regresión)
    pred_nota = regressor.predict(entrada_df)[0]

    return round(pred_nota, 2), estado_resultado