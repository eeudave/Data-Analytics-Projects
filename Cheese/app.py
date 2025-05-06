import streamlit as st

# Configuracion de la pagina
st.set_page_config(page_title="Cheese", page_icon="🧀", layout="wide") 

# CSS personalizado para cambiar el color de los títulos de navegación
st.markdown("""
<style>
/* Cambia el color de todos los títulos de navegación */
.stPageLink > div > div {
    color: #FF5733 !important;  /* Cambia este valor al color que prefieras */
}

/* Opcional: Cambia el color al pasar el mouse */
.stPageLink:hover > div > div {
    color: #C70039 !important;
}
</style>
""", unsafe_allow_html=True)

# Define the pages
main_page = st.Page("cheese.py", title="Cheese", icon="🧀")
page_2 = st.Page("recomendacion.py", title="Recomendación", icon="🔍")
page_3 = st.Page("clusterizacion.py", title="Clusterización", icon="🧬")

# Set up navigation
pg = st.navigation([main_page, page_2, page_3])

# Run the selected page
pg.run()
