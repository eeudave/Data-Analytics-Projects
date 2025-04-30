import os
import requests
import streamlit as st
import pandas as pd
import numpy as np
import time
from wordcloud import WordCloud
import matplotlib.pyplot as plt
import plotly.express as px
from PIL import Image
from streamlit_lottie import st_lottie

# Para obtener la ruta absoluta de los archivos
base_dir = os.path.dirname(os.path.abspath(__file__))  

# Configuracion de la pagina
st.set_page_config(page_title="Cheese", page_icon="🧀", layout="wide") 

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

#funcion carga lottie
def lottie_loader(url):
    r = requests.get(url)
    if r.status_code !=200:
        return None
    return r.json()

#carga css
css_loader()

#carga archivo
cheese_df = csv_loader()

email_address ="erik.eudave@gmail.com"

# Obtener la ruta absoluta del archivo gif
gif_path = os.path.join(base_dir, "images", "QuesoAzul.gif")

# Título
#st.title("🧀 Cheese: Quesos del Mundo!")

# Sidebar (filtros)
with st.sidebar:
    #st.header("Filtros")
    # Primero contamos cuántos quesos hay por país
    country_counts = cheese_df['country'].value_counts().reset_index()
    country_counts.columns = ['country', 'count']
    # Obtenemos la lista de países ordenados por cantidad de quesos (descendente)
    countries_by_cheese_count = country_counts['country'].tolist()
    selected_country = st.selectbox(
        "País", ["Todos"] + countries_by_cheese_count #sorted(cheese_df['country'].unique().tolist())
        )
    # Obtenemos la lista de tipos de leche únicos y los ordenamos
    selected_milk = st.selectbox(
        "Tipo de leche", ["Todos"] + sorted(cheese_df['milk'].dropna().unique().tolist())
        )

# Aplicar filtros
filtered_df = cheese_df.copy()
if selected_country != "Todos":
    filtered_df = filtered_df[filtered_df['country'] == selected_country]
if selected_milk != "Todos":
    filtered_df = filtered_df[filtered_df['milk'] == selected_milk]

#intro
with st.container():
    left_column, right_column = st.columns([0.2, 0.8], gap="small", vertical_alignment="center", border=False)
    
    with left_column:
        st.markdown('<div class="gif-container">', unsafe_allow_html=True)
        st.image(gif_path, width=100%)
        st.markdown('</div>', unsafe_allow_html=True)
    
    with right_column:
        st.title("Cheese: Quesos del Mundo!")
 # Mapa
with st.container():
    # Crear UNA columna (el (1) hace que devuelva una lista con 1 columna)
    columns = st.columns(1)  # Devuelve: [col1]
    # Contar la cantidad de quesos por país
    cheese_counts = filtered_df['country'].value_counts().reset_index()
    cheese_counts.columns = ['country', 'cheese_count']
    # Acceder a la primera (y única) columna de la lista
    with columns[0]:  # 👈 Usar el primer elemento de la lista
        with st.container(border=True, key="figura0"):
            st.subheader("🌍 Mapa de Quesos por País")
            # Crear el mapa
            fig = px.choropleth(cheese_counts, 
                                #geojson=geo,
                                locations='country', 
                                locationmode='country names', 
                                color='cheese_count',
                                #colorscale="sunsetdark",
                                hover_name='country',
                                #marker_opacity=0.5,
                                #marker_line_width=0,
                                color_continuous_scale='YlOrBr',)
            
            # Actualizar el layout para cambiar el color de fondo
            fig.update_layout(
                margin={"r": 0, "t": 0, "l": 0, "b": 0},
                paper_bgcolor='#082e6e',  # Color de fondo alrededor del mapa
                geo=dict(
                    bgcolor='#082e6e',     # Color de fondo del mapa
                    lakecolor='#e5ecf6',   # Color de los lagos
                    landcolor='#f0f0f0',   # Color de la tierra (áreas sin datos)
                    showland=True,
                    showlakes=True,
                    showocean=True,
                    oceancolor='#d6e9ff',  # Color del océano
                    projection_type='natural earth'
                )
            )
            
            # Mostrar el mapa en Streamlit ajustado al contenedor
            st.plotly_chart(fig, use_container_width=True)
          
# Visualizaciones 1
with st.container():
    #st.write("---")
    columns = st.columns(1)
    with columns[0]:
        with st.container(border=True, key="figura1"):
            st.subheader("🧀 Quesos por País y Tipo de Leche")
            # Paso 1: Calcular el total de quesos por país para determinar el orden
            total_by_country = filtered_df.groupby('country').size().reset_index(name='total_count') 
            total_by_country = total_by_country.sort_values('total_count', ascending=False)

            # Paso 2: Obtener la lista ordenada de países
            ordered_countries = total_by_country['country'].tolist()

            # Paso 3: Agrupar por país y tipo de leche
            milk_country_counts = filtered_df.groupby(['country', 'milk']).size().reset_index(name='count')

            # Paso 4: Crear una columna categórica ordenada para los países
            milk_country_counts['country_ordered'] = pd.Categorical(
                milk_country_counts['country'], 
                categories=ordered_countries, 
                ordered=True
            )

            # Paso 5: Ordenar primero por la columna categórica (país) y luego por conteo dentro de cada país
            milk_country_counts = milk_country_counts.sort_values(
                ['country_ordered', 'count'], 
                ascending=[True, False])

            # Crear la gráfica de barras con tipo de leche como hue (color)
            fig = px.bar(
                milk_country_counts, 
                x='country',
                y='count',
                color='milk',  # Aquí agregamos el tipo de leche como hue
                orientation='v',
                color_discrete_sequence=px.colors.sequential.Oranges_r,
                barmode='stack',  # Puedes usar 'stack' para barras apiladas o 'group' para barras agrupadas
                category_orders={"country": ordered_countries},  # Esto garantiza el orden correcto en el eje x
                height=500
            )
            fig.update_layout(
                xaxis_title="País",
                yaxis_title="Número de Quesos",
                legend_title="Tipo de Leche",
                paper_bgcolor="#082e6e",   # Fondo de la figura
                plot_bgcolor="#082e6e",    # Fondo del área del gráfico
                font=dict(color="#fc8c1c"), # Color del texto
                legend=dict(
                    font=dict(color="#f5eec6"),
                    title_font=dict(color="#fc8c1c")
                ),
                margin=dict(l=0, r=0, t=0, b=0)  # Reduce márgenes
            )
            fig.update_xaxes(tickangle=45)

            # Mostrar la gráfica en Streamlit
            st.plotly_chart(fig, use_container_width=True)

# Visualizaciones 2
with st.container():
    #st.write("---")
    columns = st.columns(1)
    with columns[0]:
        with st.container(border=True, key="figura2"):
            st.subheader("🎨 Quesos por Color y Familia")
            fig = px.sunburst(
                filtered_df, 
                path=['family', 'color'],
                color_discrete_sequence=px.colors.sequential.YlOrBr_r,
                height=500
            )
            fig.update_layout(
                paper_bgcolor="#082e6e",
                plot_bgcolor="#082e6e",
                font=dict(color="#fc8c1c"),
                margin=dict(l=0, r=0, t=0, b=0)  # Reduce márgenes
            )
            st.plotly_chart(fig, use_container_width=True)
            
# Visualizaciones 3
with st.container():
    #st.write("---")
    columns = st.columns(1)
    with columns[0]:
        with st.container(border=True, key="figura3"):
            st.subheader("👅 Relación Sabor Vs Textura")
            fig = px.scatter(
                filtered_df, 
                x='texture', 
                y='flavor',
                color='milk', 
                color_discrete_sequence=px.colors.sequential.Oranges_r,  # Paleta para categorías discretas
                hover_name='cheese',
                height=500
            )
            fig.update_layout(
                xaxis_title="Textura",
                yaxis_title="Sabor",
                legend_title="Tipo de Leche",
                paper_bgcolor="#082e6e",   # Fondo de la figura
                plot_bgcolor="#082e6e",    # Fondo del área del gráfico
                font=dict(color="#fc8c1c"), # Color del texto
                legend=dict(
                    font=dict(color="#f5eec6"),
                    title_font=dict(color="#fc8c1c")
                ),
                margin=dict(l=0, r=0, t=0, b=0)  # Reduce márgenes
            )
            fig.update_xaxes(tickangle=45)
            st.plotly_chart(fig, use_container_width=True)

# Visualizaciones 4
with st.container():
    #st.write("---")
    columns = st.columns(1)
    with columns[0]:
        with st.container(border=True, key="figura4"):
            st.subheader("👃 Principales Aromas")
            text = " ".join(filtered_df['aroma'].dropna())
            wordcloud = WordCloud(
                background_color='white',
                colormap='Oranges_r',  
                width=800,
                height=400
            ).generate(text)

            plt.imshow(wordcloud, interpolation='bilinear')
            plt.axis('off')
            st.pyplot(plt)


# Buscador de quesos
with st.container():
    #st.write("---")
    # Buscador de quesos
    st.subheader("Buscador por nombre")
    search_term = st.text_input("Escribe el nombre de un queso:")
    if search_term:
        results = filtered_df[filtered_df['cheese'].str.contains(search_term, case=False)]
        st.dataframe(results)

with st.container():
    st.write("---")
    # Dataframe
    with st.expander(f"Ver tabla de Quesos ({len(filtered_df)})", expanded=False):
        st.dataframe(
            filtered_df,
            use_container_width=True
        )    

        # --- PIE DE PÁGINA ---
st.markdown("---")
st.caption("""
    Aplicación desarrollada por [Erik Eudave ⚙️](https://github.com/eeudave/) | 
    Datos: [Kaggle Dataset](https://www.kaggle.com/datasets/umerhaddii/global-cheese-dataset/)
""")






