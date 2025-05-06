import streamlit as st
import os

# Configuracion de la pagina
st.set_page_config(page_title="Cheese", page_icon="🧀", layout="wide") 

# Para obtener la ruta absoluta de los archivos
base_dir = os.path.dirname(os.path.abspath(__file__))  

# Obtener la ruta absoluta del archivo css
css_path = os.path.join(base_dir, "style", "main.css")

#funcion carga CSS
def css_loader():
    with open(css_path) as f:
        st.markdown(f"<style>{f.read()}</style>", unsafe_allow_html=True)

#carga css
css_loader()

with st.container(border=True, key="pages"):
    # Define the pages
    main_page = st.Page("cheese.py", title="Cheese", icon="🧀")
    page_2 = st.Page("recomendacion.py", title="Recomendación", icon="🔍")
    page_3 = st.Page("clusterizacion.py", title="Clusterización", icon="🧬")

# Set up navigation
pg = st.navigation([main_page, page_2, page_3])

# Run the selected page
pg.run()
