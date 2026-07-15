import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os
from matplotlib.ticker import FuncFormatter
import xlsxwriter


# ==============================
# CONFIGURACIÓN
# ==============================

directorio_script = os.path.dirname(os.path.abspath(__file__))
ruta_archivo = os.path.join(
    directorio_script,
    'reporte_servicios_proveedor_año.csv'
)


mis_colores_hex = [
    "#FF5733", "#33FF57", "#193ACB", "#FF33A1",
    "#A133FF", "#33FFF5", "#F5FF33", "#FF8C33",
    "#16C7C0", "#1E8A0F", "#FF3333", "#5733FF"
]


def formatear_millones(x, pos):
    return f'{x/1000000:.1f}M'


# ==============================
# LECTURA ARCHIVO
# ==============================

if not os.path.exists(ruta_archivo):

    print(f"ERROR: No encuentro el archivo en: {ruta_archivo}")


else:

    df = pd.read_csv(ruta_archivo)

    df['Total'] = df.iloc[:, 1:].sum(axis=1)

    top_12 = (
        df.sort_values(
            by='Total',
            ascending=False
        )
        .head(12)
    )


    # ==============================
    # 1. GRÁFICA
    # ==============================

    plt.figure(figsize=(20,7))


    melted = top_12.melt(
        id_vars=['Proveedor'],
        value_vars=[str(year) for year in range(2015,2028)],
        var_name='Año',
        value_name='Monto'
    )


    melted['Año'] = pd.to_numeric(melted['Año'])


    sns.lineplot(
        data=melted,
        x='Año',
        y='Monto',
        hue='Proveedor',
        marker='o',
        palette=mis_colores_hex
    )


    plt.gca().yaxis.set_major_formatter(
        FuncFormatter(formatear_millones)
    )


    plt.ylim(bottom=0)

    plt.xticks(range(2015,2028))

    plt.title(
        'Tendencia de Compras: Top 12 Proveedores',
        fontsize=16
    )


    plt.tight_layout()


    plt.savefig(
        os.path.join(
            directorio_script,
            'grafica_estilo.png'
        ),
        dpi=600,
        bbox_inches='tight'
    )


    plt.close()



    # ==============================
    # 2. TABLA TOTALES
    # ==============================


    fig1, ax1 = plt.subplots(figsize=(16,5))

    ax1.axis('off')


    tabla_datos = top_12.drop(
        columns=['Total']
    ).copy()



    tabla_datos['Proveedor'] = tabla_datos['Proveedor'].apply(
        lambda x: x[:22] + '..'
        if len(x) > 22
        else x
    )


    for col in tabla_datos.columns[1:]:

        tabla_datos[col] = tabla_datos[col].apply(
            lambda x: f"${x:,.2f}"
        )


    tabla1 = ax1.table(
        cellText=tabla_datos.values,
        colLabels=tabla_datos.columns,
        cellLoc='center',
        loc='center'
    )


    tabla1.auto_set_font_size(False)
    tabla1.set_fontsize(8)



    for (fila,columna), celda in tabla1.get_celld().items():


        if columna == 0:
            celda.set_width(0.25)

        else:
            celda.set_width(0.075)


        celda.set_height(0.055)



    for i in range(len(top_12)):

        color = mis_colores_hex[
            i % len(mis_colores_hex)
        ]


        for j in range(len(tabla_datos.columns)):

            tabla1[i+1,j].set_facecolor(color)
            tabla1[i+1,j].set_alpha(0.3)



    plt.tight_layout()


    plt.savefig(
        os.path.join(
            directorio_script,
            'tabla_estilo.png'
        ),
        dpi=600,
        bbox_inches='tight',
        pad_inches=0.3
    )


    plt.close()



    # ==============================
    # 3. TABLA VALORES + VARIACIÓN %
    # ==============================


    data_years = (
        top_12
        .drop(columns=['Total'])
        .set_index('Proveedor')
    )

    # Se usara para sacar la variacion en la imagen
    pct_change = (
        data_years
        .pct_change(axis=1)
        * 100
    )

    # Se usara para sacar la variacion en el excel
    pct_change2 = (
        data_years
        .pct_change(axis=1)
    
    )

   

    rows = []
    nombres = []


    for prov in data_years.index:


        rows.append(
            data_years.loc[prov]
            .apply(lambda x: f"${x:,.2f}")
        )


        nombres.append(
            prov[:22]+'..'
            if len(prov)>22
            else prov
        )


        rows.append(
            pct_change.loc[prov]
            .apply(
                lambda x:
                f"{x:,.1f}%"
                if pd.notnull(x)
                else "-"
            )
        )


        nombres.append(
            "Variación %"
        )



    tabla_final = pd.DataFrame(rows)



    fig2, ax2 = plt.subplots(figsize=(18,10))

    ax2.axis('off')



    tabla2 = ax2.table(
        cellText=tabla_final.values,
        rowLabels=nombres,
        colLabels=tabla_final.columns,
        cellLoc='center',
        rowLoc='center',
        loc='center'
    )


    tabla2.auto_set_font_size(False)
    tabla2.set_fontsize(8)



    for (fila,columna), celda in tabla2.get_celld().items():

        if columna == -1:

            celda.set_width(0.22)

        else:

            celda.set_width(0.075)


        celda.set_height(0.045)



    for i in range(len(top_12)):

        color = mis_colores_hex[
            i % len(mis_colores_hex)
        ]


        fila_dinero = i*2+1
        fila_pct = i*2+2



        for j in range(len(tabla_final.columns)):


            if (fila_dinero,j) in tabla2.get_celld():

                tabla2[fila_dinero,j].set_facecolor(color)
                tabla2[fila_dinero,j].set_alpha(0.25)



            if (fila_pct,j) in tabla2.get_celld():

                tabla2[fila_pct,j].set_facecolor(color)
                tabla2[fila_pct,j].set_alpha(0.10)




    plt.tight_layout()



    plt.savefig(
        os.path.join(
            directorio_script,
            'tabla_completa.png'
        ),
        dpi=600,
        bbox_inches='tight',
        pad_inches=0.3
    )


    plt.close()


    print("✅ Gráfica y tablas generadas correctamente")

# ==============================
# 4. GENERAR REPORTE EXCEL
# ==============================

ruta_excel = os.path.join(
    directorio_script,
    'reporte_servicios_proveedores.xlsx'
)


with pd.ExcelWriter(
    ruta_excel,
    engine='xlsxwriter'
) as writer:


    workbook = writer.book


    # FORMATOS

    formato_moneda = workbook.add_format({
        'num_format': '$#,##0',
        'align': 'center'
    })


    formato_porcentaje = workbook.add_format({
        'num_format': '0.0%',
        'align': 'center'
    })


    formato_header = workbook.add_format({
        'bold': True,
        'bg_color': '#193ACB',
        'font_color': 'white',
        'align': 'center'
    })



    # ==============================
    # HOJA 1: TOTALES
    # ==============================


    excel_totales = top_12.drop(
        columns=['Total']
    )


    excel_totales.to_excel(
        writer,
        sheet_name='Totales Compras',
        index=False
    )


    hoja1 = writer.sheets['Totales Compras']


    for col, nombre in enumerate(excel_totales.columns):

        hoja1.write(
            0,
            col,
            nombre,
            formato_header
        )


    hoja1.set_column(
        0,
        0,
        25
    )


    hoja1.set_column(
        1,
        len(excel_totales.columns),
        14,
        formato_moneda
    )


    hoja1.freeze_panes(
        1,
        1
    )


    hoja1.autofilter(
        0,
        0,
        len(excel_totales),
        len(excel_totales.columns)-1
    )



    # ==============================
    # HOJA 2: VARIACION %
    # ==============================


    # Limpiar valores inválidos

    pct_excel = (
        pct_change2
        .replace([float('inf'), float('-inf')], None)
    )


    excel_variacion = pd.DataFrame()



    for prov in data_years.index:


        # Valores monetarios

        valores = pd.DataFrame(
            [data_years.loc[prov]]
        )


        valores.insert(
            0,
            'Proveedor',
            prov
        )



        # Porcentajes

        porcentaje = pd.DataFrame(
            [pct_excel.loc[prov]]
        )


        porcentaje.insert(
            0,
            'Proveedor',
            prov + " Variación %"
        )



        excel_variacion = pd.concat(
            [
                excel_variacion,
                valores,
                porcentaje
            ],
            ignore_index=True
        )



    excel_variacion.to_excel(
        writer,
        sheet_name='Variacion %',
        index=False
    )


    hoja2 = writer.sheets['Variacion %']



    # Encabezados

    for col, nombre in enumerate(excel_variacion.columns):

        hoja2.write(
            0,
            col,
            nombre,
            formato_header
        )



    hoja2.set_column(
        0,
        0,
        30
    )


    hoja2.set_column(
        1,
        len(excel_variacion.columns),
        14
    )



    # Escribir datos con formato correcto

    for fila in range(len(excel_variacion)):


        nombre = str(
            excel_variacion.iloc[fila,0]
        )


        fila_excel = fila + 1



        for columna in range(
            1,
            len(excel_variacion.columns)
        ):


            valor = excel_variacion.iloc[
                fila,
                columna
            ]



            # Quitar NaN e infinitos

            if (
                pd.isna(valor)
                or valor == float('inf')
                or valor == float('-inf')
            ):


                hoja2.write(
                    fila_excel,
                    columna,
                    "-"
                )

                continue



            # Filas de porcentaje

            if "Variación %" in nombre:


                hoja2.write(
                    fila_excel,
                    columna,
                    valor,
                    formato_porcentaje
                )



            # Filas monetarias

            else:


                hoja2.write(
                    fila_excel,
                    columna,
                    valor,
                    formato_moneda
                )



    hoja2.freeze_panes(
        1,
        1
    )



    # ==============================
    # HOJA 3: RANKING
    # ==============================


    ranking = (
        top_12[['Proveedor','Total']]
        .sort_values(
            by='Total',
            ascending=False
        )
    )


    ranking.to_excel(
        writer,
        sheet_name='Ranking',
        index=False
    )


    hoja3 = writer.sheets['Ranking']



    for col, nombre in enumerate(ranking.columns):

        hoja3.write(
            0,
            col,
            nombre,
            formato_header
        )


    hoja3.set_column(
        0,
        0,
        30
    )


    hoja3.set_column(
        1,
        1,
        18,
        formato_moneda
    )


    hoja3.freeze_panes(
        1,
        0
    )



print(
    "✅ Reporte Excel generado:",
    ruta_excel
)