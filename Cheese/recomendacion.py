import os
import streamlit as st
import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

# Para obtener la ruta absoluta de los archivos
base_dir = os.path.dirname(os.path.abspath(__file__))  

# Obtener la ruta absoluta del archivo css
css_path = os.path.join(base_dir, "style", "main.css")

#funcion carga CSS
def css_loader():
    with open(css_path) as f:
        st.markdown(f"<style>{f.read()}</style>", unsafe_allow_html=True)

# Obtener la ruta absoluta del archivo csv
data_path = os.path.join(base_dir, "data", "cheese_clean.csv")

#funcion carga CSV
@st.cache_data
def csv_loader() :
    data = pd.read_csv(data_path, delimiter = ",")
    #limpia nulos
    data['cheese'] = data['cheese'].fillna("Unknown")
    return (data)

#carga css
css_loader()

#carga archivo
cheese_df = csv_loader()

# Función para obtener recomendaciones basadas en la familia
@st.cache_data
def recomendar_quesos_por_familia(df, familia, top_n=5):
    # Combina columnas relevantes
    df = df.copy()
    df["combined_features"] = df[["milk", "country", "family", "type", "texture", "flavor"]].fillna("").agg(" ".join, axis=1)
    
    # Vectoriza
    vectorizer = TfidfVectorizer()
    tfidf_matrix = vectorizer.fit_transform(df["combined_features"])
    
    # Calcula similitud
    similarity_matrix = cosine_similarity(tfidf_matrix, tfidf_matrix)

    # Filtrar por familia seleccionada
    family_df = df[df["family"] == familia]

    if family_df.empty:
        return pd.DataFrame()  # Devuelve vacío si no hay coincidencias

    # Elegir uno representativo (el primero del filtro)
    idx = family_df.index[0]

    # Obtener índices más similares (excluyendo el mismo)
    similar_indices = similarity_matrix[idx].argsort()[::-1][1:top_n+1]

    # Devolver resultados
    return df.iloc[similar_indices]

with st.sidebar:
    with st.expander("🧠 ¿Cómo funciona la recomendación?", expanded=False):
        st.write(
            "Utilizamos técnicas de *Machine Learning* para analizar características de quesos "
            "(tipo de leche, país, textura, sabor y familia). "
            "Con un modelo basado en similitud de texto (*TF-IDF + Cosine Similarity*), "
            "identificamos los quesos más parecidos a la familia seleccionada y "
            "te recomendamos los 5 más similares."
        )

# Obtener la ruta absoluta del archivo gif
gif_path = os.path.join(base_dir, "images", "QuesoAzul.gif")

#intro
with st.container():
    left_column, right_column = st.columns([0.2, 0.8], gap="small", vertical_alignment="center", border=False)
    
    with left_column:
        st.markdown('<div class="gif-container">', unsafe_allow_html=True)
        st.image(gif_path, width=150)
        st.markdown('</div>', unsafe_allow_html=True)
    
    with right_column:
        st.title("Cheese: Quesos del Mundo!")

st.subheader("🔍 Recomendación de Quesos Similares")

# Obtener top 10 quesos más frecuentes
cheese_list = (
    cheese_df["cheese"]
    .value_counts()
    .head(10)
    .index
    .tolist()
)
# Definir las familias más populares de quesos
popular_families = [
    "Blue", "Brie", "Camembert", "Cheddar", "Cottage", 
    "Feta", "Gouda", "Monterey Jack", 
    "Mozzarella", "Parmesan", "Pecorino", "Swiss Cheese"
]

# Crear dos columnas: para filtros y para resultados
col_filters, col_results = st.columns([1, 2])

with col_filters:
    #st.markdown("Filtros", unsafe_allow_html=True)
    
    # Selector de familia de queso
    selected_family = st.selectbox("Selecciona una familia de queso:", options=sorted(popular_families))

    # Filtrar quesos de esa familia
    family_df = cheese_df[cheese_df["family"] == selected_family]
    
    # Número de recomendaciones
    num_recommendations = 5
    
    # Estadísticas
    st.markdown("Estadísticas", unsafe_allow_html=True)
    
    # cuántos quesos pertenecen a la familia seleccionada.
    family_count = len(cheese_df[cheese_df['family'].str.lower() == selected_family.lower()])

    st.metric(f"Quesos de tipo {selected_family}", family_count)
    
    # Países más comunes para esta familia
    if family_count > 0:
        top_countries = cheese_df[cheese_df['family'].str.lower() == selected_family.lower()]['country'].value_counts().head(3)
        st.write("Países más comunes:")
        for country, count in top_countries.items():
            if country:
                st.write(f"- {country}: {count} quesos")
    
with col_results:
    st.markdown("Quesos Recomendados:", unsafe_allow_html=True)
    
    # Obtener recomendaciones
    recomendados = recomendar_quesos_por_familia(cheese_df, selected_family, top_n=num_recommendations)
    
    if recomendados.empty:
        st.warning(f"No se encontraron quesos de tipo {selected_family} con los filtros seleccionados.")
    else:
        # Mostrar las recomendaciones
        for _, cheese in recomendados.iterrows():
            with st.expander(f"🧀 {cheese['cheese']}"):
                col1, col2 = st.columns(2)
                
                with col1:
                    st.markdown("Información básica:", unsafe_allow_html=True)
                    st.write(f"**País:** {cheese['country'] if cheese['country'] else 'No especificado'}")
                    st.write(f"**Región:** {cheese['region'] if cheese['region'] else 'No especificada'}")
                    st.write(f"**Tipo de leche:** {cheese['milk'] if cheese['milk'] else 'No especificado'}")
                    st.write(f"**Familia:** {cheese['family'] if cheese['family'] else 'No especificada'}")
                    st.write(f"**Tipo:** {cheese['type'] if cheese['type'] else 'No especificado'}")
                
                with col2:
                    st.markdown("Características:", unsafe_allow_html=True)
                    st.write(f"**Textura:** {cheese['texture'] if cheese['texture'] else 'No especificada'}")
                    st.write(f"**Corteza:** {cheese['rind'] if cheese['rind'] else 'No especificada'}")
                    st.write(f"**Color:** {cheese['color'] if cheese['color'] else 'No especificado'}")
                    st.write(f"**Sabor:** {cheese['flavor'] if cheese['flavor'] else 'No especificado'}")
                    st.write(f"**Aroma:** {cheese['aroma'] if cheese['aroma'] else 'No especificado'}")
                
                # Información adicional
                st.markdown("Vegetariano: " + ("✅ Sí" if cheese['vegetarian'] == 'True' else "❌ No" if cheese['vegetarian'] == 'False' else "❓ No especificado"), unsafe_allow_html=True)
                st.markdown("Vegano: " + ("✅ Sí" if cheese['vegan'] == 'True' else "❌ No" if cheese['vegan'] == 'False' else "❓ No especificado"), unsafe_allow_html=True)
                
                if cheese['producers']:
                    st.write(f"**Productores:** {cheese['producers']}")
                
                if cheese['url']:
                    st.markdown(f"[🔗 Más información sobre {cheese['cheese']}]({cheese['url']})")
        
        # Mostrar también una tabla con todas las recomendaciones
        st.markdown("Tabla comparativa", unsafe_allow_html=True)
        
        # Columnas a mostrar en la tabla
        display_columns = ["cheese", "milk", "country", "type", "flavor"]
        renamed_columns = {
            "cheese": "Queso",
            "milk": "Leche",
            "country": "País", 
            "type": "Tipo",
            "flavor": "Sabor"
        }
        
        # Preparar la tabla para mostrar
        table_df = recomendados[display_columns].rename(columns=renamed_columns)
        st.dataframe(table_df, hide_index=True)

# Footer
st.markdown("---")
st.markdown("Desarrollado con ❤️ y 🧀 | Sistema de Recomendación de Quesos © 2025")