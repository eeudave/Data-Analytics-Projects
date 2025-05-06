import os
import streamlit as st
import pandas as pd
import numpy as np
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.compose import ColumnTransformer
from sklearn.cluster import KMeans, AgglomerativeClustering
from sklearn.metrics import silhouette_score
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.impute import SimpleImputer
import plotly.express as px

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

# Función para realizar el preprocesamiento
def preprocess_data(df, columns_to_use):
    # Identificar columnas categóricas existentes en la selección
    categorical_columns = df[columns_to_use].select_dtypes(include=['object', 'category']).columns.tolist()
    
    # Crear un DataFrame solo con las columnas seleccionadas
    features_df = df[columns_to_use].copy()
    
    # Imputar valores faltantes en columnas categóricas
    for col in categorical_columns:
        if features_df[col].isnull().any():
            features_df[col] = features_df[col].fillna(features_df[col].mode()[0])
    
    # Crear pipeline de transformación con one-hot encoding para variables categóricas
    preprocessor = ColumnTransformer(
        transformers=[
            ('cat', OneHotEncoder(handle_unknown='ignore', sparse_output=False), categorical_columns)
        ],
        remainder='passthrough'
    )
    
    # Aplicar transformaciones
    X_transformed = preprocessor.fit_transform(features_df)
    
    return X_transformed, preprocessor

# Función para encontrar el número óptimo de clusters
def find_optimal_clusters(X, min_k=2, max_k=10):
    inertia = []
    silhouette_scores = []
    k_range = range(min_k, max_k + 1)
    
    for k in k_range:
        kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
        kmeans.fit(X)
        inertia.append(kmeans.inertia_)
        
        # Cálculo del silhouette score
        if k > 1:  # El silhouette score necesita al menos 2 clusters
            labels = kmeans.labels_
            silhouette_avg = silhouette_score(X, labels)
            silhouette_scores.append(silhouette_avg)
        else:
            silhouette_scores.append(0)
    
    return k_range, inertia, silhouette_scores

# Función para aplicar K-Means
def apply_kmeans(X, n_clusters):
    kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
    clusters = kmeans.fit_predict(X)
    return clusters, kmeans

# Función para aplicar Clustering Jerárquico
def apply_hierarchical(X, n_clusters):
    hierarchical = AgglomerativeClustering(n_clusters=n_clusters)
    clusters = hierarchical.fit_predict(X)
    return clusters

# Función para realizar PCA
def apply_pca(X, n_components=2):
    pca = PCA(n_components=n_components)
    X_pca = pca.fit_transform(X)
    return X_pca, pca

#carga css
css_loader()

#carga archivo
cheese_df = csv_loader()

with st.sidebar:
    # Parámetros de clustering
    
    clustering_method = st.sidebar.selectbox(
        "Método de clustering",
        ["K-Means", "Clustering Jerárquico", "Ambos"]
    )

    min_clusters = 2
    max_clusters = min(10, cheese_df.shape[0] - 1)
    optimal_k = st.sidebar.slider(
        "Número de clusters",
        min_value=min_clusters,
        max_value=max_clusters,
        value=4
    )

    with st.expander("🧠 ¿Cómo se realiza la Clusterización?", expanded=False):
        st.write(
            "Aplicando técnicas de *Machine Learning* para realizar el clustering de quesos basado en sus características categóricas.\n"
            "- One-Hot Encoding para variables categóricas\n"
            "- K-Means y Clustering Jerárquico\n"
            "- PCA para visualización"
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

# Inicializar variables de session_state si no existen
if 'clustering_done' not in st.session_state:
    st.session_state.clustering_done = False

selected_columns = ["milk", "country", "family", "type", "texture", "flavor"]    

# Realizar el preprocesamiento
if st.button("Realizar Clustering"):
    # Inicializar todas las variables de estado antes de procesamiento
    st.session_state.clustering_done = False  # Primero lo marcamos como falso hasta que todo se complete
    
    with st.spinner("Preprocesando datos..."):
        try:
            # Preprocesar datos
            X_transformed, preprocessor = preprocess_data(cheese_df, selected_columns)
            st.session_state.X_transformed = X_transformed
            
            # Número óptimo de clusters
            k_range, inertia, silhouette_scores = find_optimal_clusters(
                X_transformed, min_k=min_clusters, max_k=max_clusters
            )
            st.session_state.k_range = k_range
            st.session_state.inertia = inertia
            st.session_state.silhouette_scores = silhouette_scores
            
            # Aplicar clustering según el método seleccionado
            if clustering_method in ["K-Means", "Ambos"]:
                kmeans_clusters, kmeans_model = apply_kmeans(X_transformed, optimal_k)
                st.session_state.kmeans_clusters = kmeans_clusters
                st.session_state.kmeans_model = kmeans_model
            
            if clustering_method in ["Clustering Jerárquico", "Ambos"]:
                hierarchical_clusters = apply_hierarchical(X_transformed, optimal_k)
                st.session_state.hierarchical_clusters = hierarchical_clusters
            
            # Aplicar PCA para visualización
            X_pca, pca_model = apply_pca(X_transformed)
            st.session_state.X_pca = X_pca
            st.session_state.pca_model = pca_model
            
            # Guardar el DataFrame original y las columnas seleccionadas
            st.session_state.cheese_df = cheese_df
            st.session_state.selected_columns = selected_columns
            
            # Marcar el clustering como completado exitosamente
            st.session_state.clustering_done = True
            st.success("Clustering completado con éxito!")
            
        except Exception as e:
            st.error(f"Error durante el proceso de clustering: {str(e)}")
            # Asegurarse de que las variables de sesión estén limpias
            for key in ['X_transformed', 'k_range', 'inertia', 'silhouette_scores', 
                       'kmeans_clusters', 'kmeans_model', 'hierarchical_clusters', 
                       'X_pca', 'pca_model', 'cheese_df', 'selected_columns']:
                if key in st.session_state:
                    del st.session_state[key]

# Mostrar resultados si el clustering se ha realizado
if 'clustering_done' in st.session_state and st.session_state.clustering_done:
    # Verificar que todas las variables necesarias estén en session_state
    required_vars = ['k_range', 'inertia', 'silhouette_scores', 'X_pca']
    if not all(var in st.session_state for var in required_vars):
        st.error("Falta alguna variable en la sesión. Por favor, realiza el clustering nuevamente.")
        st.session_state.clustering_done = False
        st.stop()
    
    with st.container():
        #st.write("---")
        columns = st.columns(1)
        with columns[0]:
            with st.container(border=True, key="codo"):
                                
                # 1. Gráficas para determinar el número óptimo de clusters
                st.subheader("📊 Determinación del número óptimo de clusters")
                col1, col2 = st.columns(2)
                
                with col1:
                    # Método del codo con Plotly
                    fig_elbow = px.line(
                        x=list(st.session_state.k_range), 
                        y=st.session_state.inertia,
                        markers=True,
                        labels={'x': 'Número de clusters', 'y': 'Inercia'},
                        title='Método del Codo'
                    )
                    fig_elbow.update_layout(
                        paper_bgcolor="#082e6e",   # Fondo de la figura
                        plot_bgcolor="#082e6e",    # Fondo del área del gráfico
                        font=dict(color="#fc8c1c"), # Color del texto
                        margin=dict(l=0, r=5, t=0, b=0)  # Reduce márgenes
                    )
                    fig_elbow.update_traces(line_width=4)  # Cambia 4 al grosor deseado
                    st.plotly_chart(fig_elbow, use_container_width=True)
                
                with col2:
                    # Silhouette score con Plotly
                    fig_silhouette = px.line(
                        x=list(st.session_state.k_range), 
                        y=st.session_state.silhouette_scores,
                        markers=True,
                        labels={'x': 'Número de clusters', 'y': 'Silhouette Score'},
                        title='Silhouette Score por Número de Clusters'
                    )
                    fig_silhouette.update_layout(
                        paper_bgcolor="#082e6e",   # Fondo de la figura
                        plot_bgcolor="#082e6e",    # Fondo del área del gráfico
                        font=dict(color="#fc8c1c"), # Color del texto
                        margin=dict(l=0, r=5, t=0, b=0)  # Reduce márgenes
                    )
                    fig_silhouette.update_traces(line_width=4)  # Cambia 4 al grosor deseado
                    st.plotly_chart(fig_silhouette, use_container_width=True)
    
    with st.container():
        #st.write("---")
        columns = st.columns(1)
        with columns[0]:
            with st.container(border=True, key="clusters"):
                # 2. Visualización de clusters con PCA
                st.subheader("🧬 Visualización de Clusters")
                
                # Crear dataframe para visualización PCA
                pca_df = pd.DataFrame(
                    data=st.session_state.X_pca,
                    columns=['PC1', 'PC2']
                )
                
                # Añadir etiquetas de cluster según el método seleccionado
                if clustering_method in ["K-Means", "Ambos"] and 'kmeans_clusters' in st.session_state:
                    pca_df['K-Means Cluster'] = st.session_state.kmeans_clusters
                
                if clustering_method in ["Clustering Jerárquico", "Ambos"] and 'hierarchical_clusters' in st.session_state:
                    pca_df['Hierarchical Cluster'] = st.session_state.hierarchical_clusters

                # Definir paleta de colores
                paleta = [
                    '#7f3300',  # Naranja muy oscuro (casi marrón)
                    '#993d00',
                    '#b34700',
                    '#cc5900',
                    '#e67300',
                    '#ff7f0e',  # Naranja base de Plotly
                    '#ff9933',
                    '#ffb366'   # Naranja claro (sin llegar a blanco)
                ]
                
                # Visualización del PCA con Plotly
                if clustering_method == "K-Means" and 'K-Means Cluster' in pca_df.columns:
                    fig_pca = px.scatter(
                        pca_df, x='PC1', y='PC2', color='K-Means Cluster',
                        color_continuous_scale=paleta,
                        title='Clusters K-Means (PCA)'
                    )
                    fig_pca.update_layout(
                        paper_bgcolor="#082e6e",   # Fondo de la figura
                        plot_bgcolor="#082e6e",    # Fondo del área del gráfico
                        font=dict(color="#fc8c1c"), # Color del texto
                        margin=dict(l=0, r=5, t=0, b=0)  # Reduce márgenes
                    )
                    fig_pca.update_traces(marker=dict(size=15, opacity=0.7))  # tamaño fijo para todos
                    st.plotly_chart(fig_pca, use_container_width=True)
                
                elif clustering_method == "Clustering Jerárquico" and 'Hierarchical Cluster' in pca_df.columns:
                    fig_pca = px.scatter(
                        pca_df, x='PC1', y='PC2', color='Hierarchical Cluster',
                        color_continuous_scale=paleta,
                        title='Clusters Jerárquicos (PCA)'
                    )
                    fig_pca.update_layout(
                        paper_bgcolor="#082e6e",   # Fondo de la figura
                        plot_bgcolor="#082e6e",    # Fondo del área del gráfico
                        font=dict(color="#fc8c1c"), # Color del texto
                        margin=dict(l=0, r=5, t=0, b=0)  # Reduce márgenes
                    )
                    fig_pca.update_traces(marker=dict(size=15, opacity=0.7))  # tamaño fijo para todos
                    st.plotly_chart(fig_pca, use_container_width=True)
                
                elif clustering_method == "Ambos":
                    # Verificar cuáles visualizaciones podemos mostrar
                    has_kmeans = 'K-Means Cluster' in pca_df.columns
                    has_hierarchical = 'Hierarchical Cluster' in pca_df.columns
                    
                    if has_kmeans and has_hierarchical:
                        tab1, tab2 = st.tabs(["K-Means", "Clustering Jerárquico"])
                        
                        with tab1:
                            fig_kmeans = px.scatter(
                                pca_df, x='PC1', y='PC2', color='K-Means Cluster',
                                color_continuous_scale=paleta,
                                title='Clusters K-Means (PCA)'
                            )
                            fig_kmeans.update_layout(
                                paper_bgcolor="#082e6e",   # Fondo de la figura
                                plot_bgcolor="#082e6e",    # Fondo del área del gráfico
                                font=dict(color="#fc8c1c"), # Color del texto
                                margin=dict(l=0, r=5, t=0, b=0)  # Reduce márgenes
                            )
                            fig_kmeans.update_traces(marker=dict(size=15, opacity=0.7))  # tamaño fijo para todos
                            st.plotly_chart(fig_kmeans, use_container_width=True)
                        
                        with tab2:
                            fig_hierarchical = px.scatter(
                                pca_df, x='PC1', y='PC2', color='Hierarchical Cluster',
                                color_continuous_scale=paleta,
                                title='Clusters Jerárquicos (PCA)'
                            )
                            fig_hierarchical.update_layout(
                                paper_bgcolor="#082e6e",   # Fondo de la figura
                                plot_bgcolor="#082e6e",    # Fondo del área del gráfico
                                font=dict(color="#fc8c1c"), # Color del texto
                                margin=dict(l=0, r=5, t=0, b=0)  # Reduce márgenes
                            )
                            fig_hierarchical.update_traces(marker=dict(size=15, opacity=0.7))  # tamaño fijo para todos
                            st.plotly_chart(fig_hierarchical, use_container_width=True)
                    elif has_kmeans:
                        fig_kmeans = px.scatter(
                            pca_df, x='PC1', y='PC2', color='K-Means Cluster',
                            color_continuous_scale=paleta,
                            title='Clusters K-Means (PCA)'
                        )
                        fig_kmeans.update_layout(
                                paper_bgcolor="#082e6e",   # Fondo de la figura
                                plot_bgcolor="#082e6e",    # Fondo del área del gráfico
                                font=dict(color="#fc8c1c"), # Color del texto
                                margin=dict(l=0, r=5, t=0, b=0)  # Reduce márgenes
                            )
                        fig_kmeans.update_traces(marker=dict(size=15, opacity=0.7))  # tamaño fijo para todos
                        st.plotly_chart(fig_kmeans, use_container_width=True)
                        st.warning("Los clusters jerárquicos no están disponibles para visualización.")
                    elif has_hierarchical:
                        fig_hierarchical = px.scatter(
                            pca_df, x='PC1', y='PC2', color='Hierarchical Cluster',
                            color_continuous_scale=paleta,
                            title='Clusters Jerárquicos (PCA)'
                        )
                        fig_hierarchical.update_layout(
                                paper_bgcolor="#082e6e",   # Fondo de la figura
                                plot_bgcolor="#082e6e",    # Fondo del área del gráfico
                                font=dict(color="#fc8c1c"), # Color del texto
                                margin=dict(l=0, r=5, t=0, b=0)  # Reduce márgenes
                            )
                        fig_hierarchical.update_traces(marker=dict(size=15, opacity=0.7))  # tamaño fijo para todos
                        st.plotly_chart(fig_hierarchical, use_container_width=True)
                        st.warning("Los clusters K-Means no están disponibles para visualización.")
                    else:
                        st.warning("No hay clusters disponibles para visualización. Por favor, realiza el clustering nuevamente.")
    
    # 3. Análisis de clusters
    st.header("Análisis de Clusters")
    
    # Verificar que cheese_df y selected_columns estén en session_state
    if 'cheese_df' not in st.session_state or 'selected_columns' not in st.session_state:
        st.error("Faltan datos necesarios en la sesión. Por favor, realiza el clustering nuevamente.")
        st.session_state.clustering_done = False
        st.stop()
    
    # Añadir columnas de cluster al dataframe original
    results_df = st.session_state.cheese_df.copy()
    
    # Verificar si se tiene K-Means
    has_kmeans = 'kmeans_clusters' in st.session_state and clustering_method in ["K-Means", "Ambos"]
    
    # Verificar si se tiene Clustering Jerárquico
    has_hierarchical = 'hierarchical_clusters' in st.session_state and clustering_method in ["Clustering Jerárquico", "Ambos"]
    
    if has_kmeans:
        results_df['cluster_kmeans'] = st.session_state.kmeans_clusters
        
        # Características de cada cluster K-Means
        st.subheader("Características principales por cluster (K-Means)")
        
        # Seleccionar las columnas categóricas para el análisis
        cat_cols = results_df.select_dtypes(include=['object', 'category']).columns
        cat_cols = [col for col in cat_cols if col in st.session_state.selected_columns]
        
        # Crear tabs para cada cluster
        kmeans_tabs = st.tabs([f"Cluster {i}" for i in range(optimal_k)])
        
        for i, tab in enumerate(kmeans_tabs):
            with tab:
                cluster_data = results_df[results_df['cluster_kmeans'] == i]
                st.write(f"Número de quesos en el cluster: {len(cluster_data)}")
                
                # Mostrar las características más comunes en este cluster
                col1, col2 = st.columns(2)
                
                with col1:
                    st.write("**Características principales:**")
                    for col in cat_cols[:len(cat_cols)//2]:
                        if col in cluster_data.columns:
                            value_counts = cluster_data[col].value_counts()
                            if not value_counts.empty:
                                top_value = value_counts.index[0]
                                percentage = (value_counts.iloc[0] / len(cluster_data)) * 100
                                st.write(f"- **{col}**: {top_value} ({percentage:.1f}%)")
                
                with col2:
                    for col in cat_cols[len(cat_cols)//2:]:
                        if col in cluster_data.columns:
                            value_counts = cluster_data[col].value_counts()
                            if not value_counts.empty:
                                top_value = value_counts.index[0]
                                percentage = (value_counts.iloc[0] / len(cluster_data)) * 100
                                st.write(f"- **{col}**: {top_value} ({percentage:.1f}%)")
                   
    if has_hierarchical:
        results_df['cluster_hierarchical'] = st.session_state.hierarchical_clusters
        
        if not has_kmeans:
            # Si solo tenemos clustering jerárquico, mostrar sus características
            st.subheader("Características principales por cluster (Jerárquico)")
            # Implementación similar a la de K-Means...
    
    if has_kmeans and has_hierarchical:
        # Comparación de métodos
        st.subheader("Comparación de métodos de clustering")
        comparison = pd.crosstab(
            results_df['cluster_kmeans'], 
            results_df['cluster_hierarchical'],
            rownames=['K-Means'],
            colnames=['Jerárquico']
        )
        st.write(comparison)
    
