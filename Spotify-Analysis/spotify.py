import os
os.environ["OMP_NUM_THREADS"] = "1"  # Elimina el Warning al crear el modelo K-Means

import streamlit as st
import pandas as pd
import folium
import pycountry
import json
import plotly.express as px
import plotly.graph_objects as go
import matplotlib.pyplot as plt
import seaborn as sns
import random
from streamlit_folium import st_folium
from geopy.geocoders import Nominatim
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA

# Para obtener la ruta absoluta de los archivos
base_dir = os.path.dirname(os.path.abspath(__file__))  

# Configuración de la página
icon_path = os.path.join(base_dir, "visualizations", "Spotify_Primary_Logo_RGB_Green.png")
st.set_page_config(
    page_title="Analisis de Popularidad Spotify",
    page_icon=icon_path,  # Ruta de la imagen del ícono
    layout="wide"
)

# Título y descripción
#st.title("Analisis de Popularidad Spotify Global")

# Obtener la ruta absoluta del archivo
data_path = os.path.join(base_dir, "data", "spotify_clean.csv")

# Función para cargar el DataFrame (se cachea para no recargarlo cada vez)
@st.cache_data
def cargar_datos():
    data = pd.read_csv(data_path,delimiter = ",")
    # Cambiamos el formato de las fechas
    data['snapshot_date'] = pd.to_datetime(data['snapshot_date'], format='%Y-%m-%d')
    data['album_release_date'] = pd.to_datetime(data['album_release_date'], format='%Y-%m-%d')    
    return (data)

# Función para cargar el archivo GeoJSON (Carga el mapa mundial una sola vez)
@st.cache_data
def cargar_geojson(ruta_archivo):
    with open(ruta_archivo, "r", encoding="utf-8") as f:
        return json.load(f)

# Función para obtener el código alpha-2 de un país
def obtener_codigo_pais(nombre_pais):
    try:
        pais = pycountry.countries.get(name=nombre_pais)
        return pais.alpha_2  # Código alpha-2 (por ejemplo, "MX" para México)
    except AttributeError:
        return 'Global'

# Funcion para traer el nombre del pais
def get_country_name(country_code):
    if isinstance(country_code, str):  # Asegura que es un string
        country = pycountry.countries.get(alpha_2=country_code.upper())  # Convierte a mayúsculas por si acaso
        if country:
            return country.name
    return None  # Devuelve None si no se encuentra el país

# Función para obtener coordenadas de un país
def get_coordenadas(codigo):
    # Inicializar el geocodificador
    geolocator = Nominatim(user_agent="geoapiEudave")
    pais = pycountry.countries.get(alpha_2=codigo.upper())
    if pais:
        # Obtener coordenadas usando Geopy
        location = geolocator.geocode(pais.name)
        if location:
            return (location.latitude, location.longitude)
        else:
            #print(f"No se encontraron coordenadas para {pais.name}.")
            return (20, 0)
    else:
        #print(f"País o código '{codigo}' no encontrado.")
        return (20, 0) # Si no se encuentra, devolver coordenadas del mundo

# Agrega mapas que no estan en json por codio -99
def style_function(feature):
    country_code = feature["properties"]["iso_a2"]
    country_name = feature["properties"]["name"]
    
    # Si el país tiene código -99, intentar obtener el código correcto por nombre
    if country_code == "-99":
        correct_code = obtener_codigo_pais(country_name)
        if correct_code:
            country_code = correct_code
    
    return {
        "fillColor": "#1ED760" if country_code in codigos_paises else "#FFFFFF",
        "color": "black",
        "weight": 1,
        "fillOpacity": 0.3 if country_code in codigos_paises else 0.1,
    }

# Resalta mapas que no estan en json por codio -99
def highlight_function(feature):
    country_code = feature["properties"]["iso_a2"]
    country_name = feature["properties"]["name"]
    
    # Si el país tiene código -99, intentar obtener el código correcto por nombre
    if country_code == "-99":
        correct_code = obtener_codigo_pais(country_name)
        if correct_code:
            country_code = correct_code

    # Verificar si es el país seleccionado
    is_selected = (country_code == codigo_pais) or (country_name == pais_seleccionado)        
    
    return {
        "fillColor": "#1ED760" if feature["properties"]["iso_a2"] == codigo_pais else "#FFFFFF",
        "color": "black",
        "weight": 1,
        "fillOpacity": 0.9 if feature["properties"]["iso_a2"] == codigo_pais else 0.1,
    }    

# Cargar datos
df = cargar_datos()      

# Obtener la ruta absoluta del archivo
map_path = os.path.join(base_dir, "data", "custom.geo.json")

# Cargar el archivo GeoJSON
geojson_data = cargar_geojson(map_path)

# Lista de nombres de países 
nombres_paises = sorted(df['country_name'].unique())

# Traemos los codigos de los paises
codigos_paises = []
for x in nombres_paises:
    codigos_paises.append(obtener_codigo_pais(x)) 

codigo_pais = 'Global' # Valor por default

# Filtramos toda la informacion del pais
canciones_pais = df[df['country'] == codigo_pais]

# Filtrar solo la última fecha disponible en snapshot_date
canciones_uf = canciones_pais[canciones_pais['snapshot_date'] == canciones_pais['snapshot_date'].max()]

# Sacamos el ranking de la ultima semana
canciones_ordenadas = canciones_uf.sort_values(by='past_week_rank', ascending=True)

# Estilo personalizado para selectbox con fondo negro y borde verde ETC
st.markdown("""
    <style>
    /* Metric */
    .custom-metric {
        background-color: black;
        color: white;
        padding: 12px;
        border-radius: 10px;
        border: 3px solid #1ED760;
        text-align: center;
        margin: 0px;
    }
    .custom-metric .label {
        font-size: 0.9rem;
        #font-weight: bold;
    }
    .custom-metric .value {
        font-size: 1.5rem;
        font-weight: bold;
    }

    /* Selectbox en el sidebar */
    [data-testid="stSelectbox"] > div > div > div {
        background-color: black !important; 
        color: #FFFFFF !important;
        border: 2px solid #1ED760 !important;  Borde verde de Spotify 
        border-radius: 8px !important; 
    }

    /* Ícono del dropdown */
    [data-testid="stSelectbox"] svg {
        fill: #FFFFFF !important;  /* Hace que el icono sea blanco */
        color: #FFFFFF !important; /* Asegura que el color del icono también sea blanco */
    }

    /* Texto pestañas */
    .stTabs [data-baseweb="tab-list"] button [data-testid="stMarkdownContainer"] p {
        font-size: 18px;  /* Tamaño de la fuente */
        /*font-weight: bold;   Negrita */
        padding-left: 10px !important;
        padding-right: 10px !important;
    }

    /* Ajustar el ancho de las pestañas */
    .stTabs {
        width: 100% !important;  /* Usa el 100% del ancho */
        padding-left: 0px !important;
        padding-right: 0px !important;
    }

    /* Cambiar color de la pestaña seleccionada */
    .stTabs [data-baseweb="tab-list"] button[aria-selected="true"] {
        color: #1ED760 !important;  /* Texto verde */
        border-bottom: 3px solid #1ED760 !important;  /* Línea inferior verde */
        /*font-weight: bold !important;  Negrita */
        border-radius: 15px 15px 0px 0px !important; /* Bordes redondeados arriba */
        padding: 10px 20px !important; /* Ajustar padding */
    }

    /* Color de las pestañas no seleccionadas */
    .stTabs [data-baseweb="tab-list"] button {
        color: white !important;  /* Texto blanco */
        background-color: black !important; /* Fondo negro */
        border-radius: 15px 15px 0px 0px !important; /* Bordes redondeados arriba */
        padding: 10px 20px !important;
    }

    /* Efecto hover en las pestañas */
    .stTabs [data-baseweb="tab-list"] button:hover {
        color: #1ED760 !important;
    }

    /* Ajustar el ancho y color del sidebar */
    [data-testid="stSidebar"] {
        min-width: 200px !important;  /* Ancho mínimo */
        max-width: 300px !important;  /* Ancho máximo */
        width: 100% !important;       /* Usa el 100% del ancho disponible */
        background-color: white !important; /* Fondo blanco en el sidebar */
    }

    /* Reducir márgenes dentro del sidebar */
    .stSidebar .stVerticalBlock {
        padding-left: 0px !important;
        padding-right: 0px !important;
    }

    /* Ajustes boton */
    div.stButton > button {
        background-color: black !important;
        color: white !important;
        border-radius: 8px;
        border: 2px solid #1ED760;  /* Verde Spotify */
        font-size: 18px;
        font-weight: bold;
        padding: 10px 20px;
    }
    
    /* Efecto hover boton */
    div.stButton > button:hover {
        background-color: #333333 !important;  /* Gris oscuro */
        color: #1ED760 !important;
        border: 2px solid #1ED760;  /* Verde Spotify */
    }

    /* Contenedor del slider */
    [data-testid="stSlider"] {
        background-color: black !important; /* Fondo negro */
        border: 3px solid #1ED760 !important; /* Borde verde */
        border-radius: 8px !important; /* Bordes redondeados */
        padding: 10px !important; /* Espaciado interno */
    }

    /* Cambiar color del texto dentro del slider */
    [data-testid="stSlider"] div {
        color: white !important; /* Texto blanco */
        font-size: 18px !important;
    }

    /* Cambiar el color del círculo (thumb) del slider */
    [data-baseweb="slider"] [role="slider"] {
        background-color: #1ED760 !important; /* Verde Spotify */
        border: 2px solid white !important; /* Borde blanco */
    } 

    /* Cambiar fondo del expander */
    div[data-testid="stExpander"] {
        font-size: 20px !important;
        background-color: black !important;
        color: white !important;
        border: 2px solid #1ED760 !important; /* Verde Spotify */
        border-radius: 10px !important;
    }
    /* Cambiar color del texto cuando el expander está en hover */
    div[data-testid="stExpander"]:hover {
        color: #1ED760 !important; /* Verde Spotify */
    }

    /* Cambiar color del texto dentro del Multiselect */
    [data-testid="stMultiSelect"] div {
        color: black !important; /* Texto blanco */
        font-size: 18px !important;
    }

    /* Cambiar el fondo y el texto del multiselect */
    [data-testid="stMultiSelect"] > div > div > div {
        background-color: black !important; /* Fondo negro */
        color: white !important; /* Texto blanco */
    }

    /* Ícono del Multiselect */
    [data-testid="stMultiSelect"] svg {
        fill: #FFFFFF !important;  /* Hace que el icono sea blanco */
        color: #FFFFFF !important; /* Asegura que el color del icono también sea blanco */
    }

    /* Cambiar el fondo de los valores seleccionados en el multiselect */
    [data-testid="stMultiSelect"] [data-baseweb="tag"] {
        background-color: #1ED760 !important; /* Fondo verde */
        color: black !important; /* Texto negro */
    }

    /* Cambiar el color del texto dentro de los valores seleccionados */
    [data-testid="stMultiSelect"] [data-baseweb="tag"] span {
        color: black !important; /* Texto negro */
    }

    /* Cambiar el fondo y el texto del menú desplegable OK */ 
    [data-baseweb="popover"] {
        background-color: black !important; /* Fondo negro */
        color: white !important; /* Texto blanco */
    }

    /* Cambiar el fondo y el texto de las opciones en el menú desplegable OK */ 
    [data-baseweb="popover"] [role="option"] {
        background-color: black !important; /* Fondo negro */
        color: white !important; /* Texto blanco */
    }

    /* Cambiar el fondo y el texto de las opciones seleccionadas en el menú desplegable OK */
    [data-baseweb="popover"] [role="option"][aria-selected="true"] {
        background-color: #1ED760 !important; /* Fondo verde */
        color: black !important; /* Texto negro */
    }

    </style>
    """, unsafe_allow_html=True)

# Sidebar: Seleccionar país
with st.sidebar:
    # Logo Spotify
    logo_path = os.path.join(base_dir, "visualizations", "Spotify_Full_Logo_RGB_Black.png")
    st.image(logo_path, width=220, use_container_width=False)
    #st.header("Selecciona un país")
    nombres_paises = ["Global"] + sorted(nombres_paises)
    pais_seleccionado = st.selectbox("País:", nombres_paises, index=0)
    
    # Si se selecciona un país, centrar el mapa en ese país
    if pais_seleccionado:
        # Obtener el código alpha-2 del país seleccionado
        codigo_pais = obtener_codigo_pais(pais_seleccionado)
    
        if codigo_pais:
            # Filtramos canciones del pais seleccionado
            canciones_pais = df[df['country'] == codigo_pais]
            # Filtrar solo la última fecha disponible en snapshot_date
            canciones_uf = canciones_pais[canciones_pais['snapshot_date'] == canciones_pais['snapshot_date'].max()]

            # Sacamos el ranking de la ultima semana
            canciones_ordenadas = canciones_uf.sort_values(by='past_week_rank', ascending=True)

            # Lista desplegable para seleccionar la canción
            cancion_seleccionada = st.selectbox(f"Selecciona una canción de {pais_seleccionado}:", canciones_ordenadas['name'].unique())
            datos_cancion = canciones_ordenadas[canciones_ordenadas['name'] == cancion_seleccionada]

            # Obtener el spotify_id de la canción seleccionada
            spotify_id = canciones_ordenadas[canciones_ordenadas['name'] == cancion_seleccionada]['spotify_id'].values[0]

            # Reproductor Spotify con la cancion seleccionada
            spotify_iframe = f"""
            <iframe src="https://open.spotify.com/embed/track/{spotify_id}?utm_source=generator&theme=0" 
                    width="230" 
                    height="230" 
                    frameborder="0" 
                    allowtransparency="true" 
                    allow="encrypted-media">
            </iframe>
            """

            # Mostrar el reproductor de Spotify en la barra lateral
            st.components.v1.html(spotify_iframe, height=250)

# Crear pestañas para organizar el contenido
tab_analisis, tab_clustering = st.tabs(["Análisis General", "Clustering de Canciones"])

# PESTAÑA 1: ANÁLISIS GENERAL
with tab_analisis:

    # Mostrar estadísticas rápidas
    #st.header("Estadísticas Generales")

    col1, col2, col3, col4 = st.columns(4)

    # Métricas personalizadas
    with col1:
        st.markdown(
            f'<div class="custom-metric">'
            f'  <div class="label">Total de Canciones</div>'
            f'  <div class="value">{canciones_pais["name"].nunique():,}</div>'
            f'</div>',
            unsafe_allow_html=True
        )

    with col2:
        st.markdown(
            f'<div class="custom-metric">'
            f'  <div class="label">Artistas Únicos</div>'
            f'  <div class="value">{canciones_pais["main_artist"].nunique():,}</div>'
            f'</div>',
            unsafe_allow_html=True
        )

    with col3:
        st.markdown(
            f'<div class="custom-metric">'
            f'  <div class="label">Popularidad Promedio</div>'
            f'  <div class="value">{canciones_pais["popularity"].mean():.2f}/100</div>'
            f'</div>',
            unsafe_allow_html=True
        )

    with col4:
        st.markdown(
            f'<div class="custom-metric">'
            f'  <div class="label">Ranking Promedio</div>'
            f'  <div class="value">{canciones_pais["past_week_rank"].mean():.2f}/50</div>'
            f'</div>',
            unsafe_allow_html=True
        )

    # División de la pantalla central en 8 secciones
    #st.header("Panel de Análisis de Popularidad")

    # Creamos un layout de 2x4 para las 8 secciones
    col_izq, col_der = st.columns(2)

    # SECCIÓN 1: Mapa (Arriba a la izquierda)
    with col_izq:
        st.subheader(f"Mapa {pais_seleccionado or 'Global'}")
        
        # Mapa
        #st.header("Mapa Global o del Pais seleccionado")
        
        # Coordenadas iniciales (centro del mundo)
        coordenadas = (20, 0)  # Latitud 20, Longitud 0
        zoom = 1  # Nivel de zoom inicial

        # Si se selecciona un país, centrar el mapa en ese país
        if pais_seleccionado:
            # Obtener el código alpha-2 del país seleccionado
            codigo_pais = obtener_codigo_pais(pais_seleccionado)
            
            if codigo_pais:
                # Obtener las coordenadas del país seleccionado
                coordenadas = get_coordenadas(codigo_pais)
                
                # Verificar que las coordenadas sean válidas
                if not (-90 <= coordenadas[0] <= 90) or not (-180 <= coordenadas[1] <= 180):
                    st.error("Coordenadas no válidas. Asegúrate de que la latitud esté entre -90 y 90, y la longitud entre -180 y 180.")
                    st.stop()  # Detener la ejecución si las coordenadas no son válidas
                
                # Aumentar el zoom para enfocar el país
                if codigo_pais == 'Global':
                    zoom = 1
                else:    
                    zoom = 3
            else:
                st.error(f"No se encontró el código alpha-2 para {pais_seleccionado}.")
                st.stop()  # Detener la ejecución si no se encuentra el código alpha-2

        # Crear un mapa centrado en las coordenadas calculadas
        m = folium.Map(location=coordenadas, zoom_start=zoom, tiles=None)

        #folium.TileLayer('CartoDB positron', opacity=0).add_to(m)  # Hace invisible el fondo predeterminado
        
        # Muestra los 73 paises resaltados
        folium.GeoJson(
            geojson_data,
            name="geojson",
            style_function=style_function,
            tooltip=folium.GeoJsonTooltip(
                fields=['name'],
                aliases=['País:'],
                style=("background-color: white; color: black; font-family: arial; font-size: 12px; padding: 10px;")
            )
        ).add_to(m)

        # Resaltar el país seleccionado en el mapa
        if pais_seleccionado and codigo_pais:
            folium.GeoJson(
                geojson_data,
                name="geojson",
                style_function=highlight_function,
                tooltip=folium.GeoJsonTooltip(
                    fields=['name'],
                    aliases=['País:'],
                    style=("background-color: white; color: black; font-family: arial; font-size: 12px; padding: 10px;")
                )
            ).add_to(m)

            if pais_seleccionado != "Global":
                # Agregar un marcador en el país seleccionado
                folium.Marker(
                    location=coordenadas,
                    popup=pais_seleccionado,
                    icon=folium.Icon(color="black", icon="star")
                ).add_to(m)

        # Mostrar el mapa en Streamlit
        st_folium(m, width="100%", height="400")


    # SECCIÓN 2: Correlacion (arriba a la derecha)
    with col_der:
        # Correlación entre características
        st.subheader("Correlación entre Características")
        corr_cols = ['danceability' ,'energy', 'key', 'mode', 'valence', 'loudness']
        corr_matrix = canciones_pais[corr_cols].corr().round(2)

        # Crear el mapa de calor con Plotly
        fig_corr = px.imshow(
            corr_matrix,
            text_auto=True,  # Muestra los valores de correlación en las celdas
            color_continuous_scale='Greens',  # Escala de colores verde
            labels=dict(x="Características", y="Características", color="Correlación"),
            x=corr_cols,
            y=corr_cols,
        )

        # Ajustar el diseño del gráfico
        fig_corr.update_layout(
            #title="Correlación entre Características",
            xaxis_nticks=len(corr_cols),
            yaxis_nticks=len(corr_cols),
            template="plotly_dark",  # Tema oscuro (puedes cambiarlo)
            coloraxis_showscale=False  #,  # Ocultar la barra de colores
            #xaxis_title_font=dict(size=18),  # Título del eje X más grande
            #yaxis_title_font=dict(size=18)   # Título del eje Y más grande
        )

        st.plotly_chart(fig_corr, use_container_width=True)

    # Nueva fila para otras dos secciones
    col_izq2, col_der2 = st.columns(2)

    # SECCIÓN 3: Características Musicales (Abajo a la izquierda)
    with col_izq2:
        st.subheader(f"Características Musicales")
        caracteristicas = ['key_name' ,'energy', 'danceability', 'mode', 'time_signature', 'is_explicit']
        caracteristica_seleccionada = st.selectbox("Seleccione característica a analizar:", caracteristicas)

        # Box plot de la característica por género
        fig_box = px.box(
            canciones_pais,
            x=caracteristica_seleccionada,
            y='popularity',
            color=caracteristica_seleccionada,
            color_discrete_sequence=px.colors.sequential.Greens_r,  # Escala de verdes para categorías
            labels={'popularity': 'Popularidad'}
            #title=f'Distribución de Popularidad por {caracteristica_seleccionada}'
        )
        # Ajustar el diseño del gráfico
        fig_box.update_layout(
            template="plotly_dark",  # Tema oscuro (puedes cambiarlo)
            coloraxis_showscale=False  # Ocultar la barra de colores
        )

        st.plotly_chart(fig_box, use_container_width=True)

    # SECCIÓN 4: scatterplot (Abajo a la derecha)
    with col_der2:
        # Crear scatterplot con Plotly
        st.subheader("Características Vs Popularidad")
        caracterist = ['duration_min' ,'valence', 'speechiness', 'acousticness', 'loudness', 'instrumentalness', 'liveness']
        caracteristica_selec = st.selectbox("Seleccione una característica", caracterist)

        fig_escatter = px.scatter(
            canciones_pais,
            x=caracteristica_selec,
            y='popularity',
            color='popularity',
            color_continuous_scale="greens",  # Escala de colores en verde
            labels={caracteristica_selec: caracteristica_selec, "popularity": "Popularidad"}#,
            #title=f"Relación entre {caracteristica_selec} Vs Popularidad"
        )
        # Ajustar el diseño del gráfico
        fig_escatter.update_layout(
            template="plotly_dark",  # Tema oscuro (puedes cambiarlo)
            coloraxis_showscale=False  # Ocultar la barra de colores
        )
        # Aumentar tamaño de los círculos
        fig_escatter.update_traces(
            marker=dict(
                size=14,  # Tamaño de los círculos
                opacity=0.7  # Opacidad de los círculos (70% opaco)
            )
        ) 

        st.plotly_chart(fig_escatter, use_container_width=True)

    # Nueva fila para otras dos secciones
    col_izq3, col_der3 = st.columns(2)

    # SECCIÓN 5: Top 10 (Abajo a la izquierda)
    with col_izq3:
        st.subheader("Top 10 Artistas Más Populares")

        # Filtrar solo las canciones con popularidad mayor a 90
        canciones_filtradas = canciones_pais[canciones_pais['popularity'] > 85] 

        # Top 10 Artistas más Populares
        top_artistas = canciones_filtradas.groupby('main_artist')['popularity'].mean().sort_values(ascending=False).head(10)
        
        # Gráfico de barras para top 10
        fig_top10 = px.bar(
            top_artistas, 
            x=top_artistas.values, 
            y=top_artistas.index, 
            orientation="h",  # Barras horizontales
            labels={"main_artist": "Artista", "popularity": "Popularidad"},
            color="popularity",
            color_continuous_scale="greens")  # Escala de colores en verde

        # Ajustar diseño
        fig_top10.update_layout(
            xaxis_title="Popularidad Promedio",
            yaxis_title="Artista",
            yaxis=dict(categoryorder="total ascending"),  # Ordenar de menor a mayor
            template="plotly_dark",  # Tema oscuro (puedes cambiarlo)
            coloraxis_showscale=False  # Ocultar la barra de colores
        )
        st.plotly_chart(fig_top10, use_container_width=True)

    # SECCIÓN 6: Top Canciones (Abajo a la derecha)
    with col_der3:
        st.subheader("Top 10 Artistas en Ranking")

        # Filtrar solo las canciones con ranking en el top 10
        canciones_filtradas1 = canciones_pais[canciones_pais['past_week_rank'] <= 10] 

        # Top 10 Artistas con mejor ranking
        top_artistas1 = canciones_filtradas1.groupby('main_artist')['past_week_rank'].mean().sort_values(ascending=True).head(10)

        # Gráfico de barras para top 10
        fig_top10a = px.bar(
            top_artistas1, 
            x=top_artistas1.values, 
            y=top_artistas1.index, 
            orientation="h",  # Barras horizontales
            labels={"main_artist": "Artista", "past_week_rank": "Ranking"},
            color='past_week_rank',  # Colorear por el valor del ranking
            color_continuous_scale="greens_r"  # Escala de colores en verde invertida
        )

        # Ajustar diseño
        fig_top10a.update_layout(
            xaxis_title="Ranking Promedio",
            yaxis_title="Artista",
            template="plotly_dark",  # Tema oscuro (puedes cambiarlo)
            coloraxis_showscale=False,  # Ocultar la barra de colores
            yaxis=dict(
                categoryorder="total descending"#,  # Ordenar de mayor a menor
                #side="right"  # Mover el eje Y (artistas) al lado derecho
            ),
            margin=dict(l=100, r=100, t=50, b=50)
        )
        # Mostrar la gráfica en Streamlit
        st.plotly_chart(fig_top10a, use_container_width=True)

    # Nueva fila para las otras dos secciones
    col_izq4, col_der4 = st.columns(2)

    # SECCIÓN 7: Top 5 Popuarity (Abajo a la izquierda)
    with col_izq4:
        st.subheader("Cambio de Popularidad por dia")
        
        # Obtener la cantidad real de canciones únicas disponibles
        num_canciones = min(3, len(canciones_filtradas['name'].unique()))
        # Seleccionar 3 canciones aleatorias sin repetir
        canciones_aleatorias = random.sample(list(canciones_filtradas['name'].unique()), num_canciones)

        # Filtrar el dataframe con solo esas 5 canciones
        graf_popularity = canciones_filtradas[canciones_filtradas['name'].isin(canciones_aleatorias)]
        
        # Gráfico de líneas para mostrar el cambio en la popularidad a lo largo del tiempo
        fig_pd = px.line(
            graf_popularity,
            x='snapshot_date',  # Eje X: Fecha (snapshot_date)
            y='popularity',     # Eje Y: Popularidad
            color='name',       # Líneas separadas por nombre de la canción
            #title="Cambio en la Popularidad de las 5 Canciones Más Populares",
            labels={"snapshot_date": "Fecha", "popularity": "Popularidad", "name": "Canción"},
            color_discrete_sequence=px.colors.sequential.Greens_r
        )
        # Ajustar diseño
        fig_pd.update_layout(
            xaxis_title="Fecha",
            yaxis_title="Popularidad",
            template="plotly_dark",  # Tema oscuro (puedes cambiarlo)
            coloraxis_showscale=False,
            legend_title="Canción"   # Título de la leyenda
        )
        # Mostrar la gráfica en Streamlit
        st.plotly_chart(fig_pd, use_container_width=True)

    # SECCIÓN 8: Top 5 Ranking (Abajo a la derecha)
    with col_der4:
        st.subheader("Cambio de Ranking por dia")

        # Obtener la cantidad real de canciones únicas disponibles
        num_canciones1 = min(3, len(canciones_filtradas1['name'].unique()))
        # Seleccionar 3 canciones aleatorias sin repetir
        canciones_aleatorias1 = random.sample(list(canciones_filtradas1['name'].unique()), num_canciones1)

        # Filtrar el dataframe con solo esas 5 canciones
        graf_ranking = canciones_filtradas1[canciones_filtradas1['name'].isin(canciones_aleatorias1)]

        # Gráfico de líneas para mostrar el cambio en la popularidad a lo largo del tiempo
        fig_rd = px.line(
            graf_ranking,
            x='snapshot_date',  # Eje X: Fecha (snapshot_date)
            y='daily_rank',     # Eje Y: Ranking
            color='name',       # Líneas separadas por nombre de la canción
            #title="Cambio en la Popularidad de las 5 Canciones Más Populares",
            labels={"snapshot_date": "Fecha", "daily_rank": "Ranking", "name": "Canción"},
            color_discrete_sequence=px.colors.sequential.Greens_r
        )

        # Ajustar diseño
        fig_rd.update_layout(
            xaxis_title="Fecha",
            yaxis_title="Ranking",
            template="plotly_dark",  # Tema oscuro (puedes cambiarlo)
            coloraxis_showscale=False,
            legend_title="Canción",  # Título de la leyenda
            yaxis=dict(autorange="reversed")  # Invertir el eje Y para que el ranking 1 esté arriba
        )
        # Mostrar la gráfica en Streamlit
        st.plotly_chart(fig_rd, use_container_width=True)        
    
    # Obtener canciones únicas
    canciones_unicas = canciones_pais.drop_duplicates(subset=['spotify_id']) 

    # Tabla complementaria
    with st.expander(f"Ver tabla de datos de éxitos para {pais_seleccionado or 'Global'}"):
        st.dataframe(
            canciones_unicas,
            use_container_width=True
        )

# PESTAÑA 2: CLUSTERING DE CANCIONES
with tab_clustering:
    
    st.header(f"Clustering de Canciones para {pais_seleccionado or 'Global'}")

    st.write("""
    Este análisis agrupa canciones con características similares utilizando el algoritmo K-means.
    Puedes seleccionar las características que deseas incluir en el análisis y el número de clusters.
    """)

    # Selección de características para clustering
    # st.subheader("Configuración del Clustering")
    col_cluster1, col_cluster2 = st.columns(2)

    with col_cluster1:
        features_clustering = st.multiselect(
            "Selecciona características para el clustering:",
            options=['danceability' ,'energy', 'key', 'mode', 'valence', 'tempo', 'time_signature'],
            default=['energy', 'danceability', 'valence']
        )

    with col_cluster2:
        n_clusters = st.slider("Número de clusters:", min_value=2, max_value=10, value=4)

    if st.button("Ejecutar Clustering") and len(features_clustering) > 0:
        # Preparar datos para clustering con canciones popalidad > 90 y unicas
        X = canciones_unicas[features_clustering].copy()
            
        # Normalizar datos
        scaler = StandardScaler()
        X_scaled = scaler.fit_transform(X)
            
        # Aplicar K-means
        kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
        clusters = kmeans.fit_predict(X_scaled)
            
        # Añadir clusters al dataframe
        df_clusters = canciones_unicas.copy()
        df_clusters['cluster'] = clusters
            
        # Visualización 2D de clusters usando PCA
        col_viz1, col_viz2 = st.columns(2)
            
        with col_viz1:
            st.subheader("Visualización de Clusters con PCA")
            # Reducir dimensionalidad para visualización
            pca = PCA(n_components=2)
            components = pca.fit_transform(X_scaled)
            
            # Crear dataframe para visualización
            df_viz = pd.DataFrame({
                'comp1': components[:, 0],
                'comp2': components[:, 1],
                'cluster': clusters,
                'cancion': canciones_unicas['name'].values,
                'artista': canciones_unicas['main_artist'].values,
                'popularidad': canciones_unicas['popularity'].values
            })

            # Calcular los centroides
            centroides = df_viz.groupby('cluster')[['comp1', 'comp2']].mean().reset_index()
            
            # Gráfico de dispersión con clusters
            fig_clusters = px.scatter(
                df_viz, 
                x='comp1', 
                y='comp2', 
                color='cluster',
                hover_data=['cancion', 'artista', 'popularidad'],
                labels={'comp1': 'Componente 1', 'comp2': 'Componente 2', 'cluster': 'Cluster'},
                #title='Visualización de Clusters usando PCA',
                #color_discrete_sequence=px.colors.qualitative.Plotly,
                color_continuous_scale=px.colors.qualitative.G10
            )
            # Aumentar tamaño de los círculos
            fig_clusters.update_traces(
                marker=dict(
                    size=16,  # Tamaño de los círculos
                    opacity=0.7  # Opacidad de los círculos (70% opaco)
                )
            )

            # Agregar los centroides al gráfico
            fig_clusters.add_trace(
                go.Scatter(
                    x=centroides['comp1'],  # Coordenada X de los centroides
                    y=centroides['comp2'],  # Coordenada Y de los centroides
                    mode='markers',  # Modo de marcadores
                    marker=dict(
                        symbol='star',  # Usar una estrella como marcador
                        size=15,  # Tamaño del marcador
                        color='black',  # Color del marcador
                        line=dict(width=2, color='white')  # Borde blanco para mayor visibilidad
                    ),
                    name='Centroides',  # Nombre de la leyenda
                    hoverinfo='none'  # Ocultar información al pasar el cursor
                )
            ) 

            st.plotly_chart(fig_clusters, use_container_width=True)
    
        with col_viz2:
            st.subheader("Características por Cluster")
            # Características promedio por cluster
            cluster_means = df_clusters.groupby('cluster')[features_clustering].mean()
            
            # Visualizar características por cluster
            fig_features = px.bar(
                cluster_means, 
                x=cluster_means.index,  # Cluster en el eje X
                y=cluster_means.columns,  # Características en el eje Y
                labels={'x': 'Cluster', 'value': 'Valor promedio'},
                #title='Características promedio por Cluster',
                barmode='group',  # Barras separadas, no apiladas
                color_discrete_sequence=px.colors.sequential.Greens_r  # Escala de verdes
            )
            
            st.plotly_chart(fig_features, use_container_width=True)
        
        # Tabla con ejemplos de cada cluster
        st.subheader("Ejemplos de Canciones por Cluster")
        
        for i in range(n_clusters):
            with st.expander(f"Cluster {i}"):
                ejemplos = df_clusters[df_clusters['cluster'] == i].sort_values('popularity', ascending=False).head(10)
                st.write(f"**Número de canciones en Cluster {i}:** {len(df_clusters[df_clusters['cluster'] == i])}")
                st.dataframe(ejemplos[['name', 'main_artist', 'popularity', 'past_week_rank', 'cluster'] + features_clustering])

# Pié de página
#st.markdown("---")
#st.markdown("Dashboard creado con Streamlit para análisis de popularidad Spotify")