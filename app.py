from flask import Flask, render_template, request, redirect, url_for, session
import urllib.parse

app = Flask(__name__)
app.secret_key = "sereia_verdinha_chave"

plantas = [
    {
        "id": 1,
        "nome": "Alocasia Cuprea",
        "preco": "120,00",
        "imagem": "alocasia_cuprea.JPG",
        "descricao": "Folhas metálicas únicas e muito decorativas."
    },
    {
        "id": 2,
        "nome": "Asplênio Rabo de Peixe",
        "preco": "45,00",
        "imagem": "asplenio_rabo_de_peixe.JPG",
        "descricao": "Planta verde vibrante ideal para interiores."
    },
    {
        "id": 3,
        "nome": "Cacto Gymnocalycium",
        "preco": "35,00",
        "imagem": "cacto_gymnocalycium.JPG",
        "descricao": "Cacto compacto e fácil de cuidar."
    },
    {
        "id": 4,
        "nome": "Criptanthus",
        "preco": "50,00",
        "imagem": "criptanthus.JPG",
        "descricao": "Planta exótica com formato estrelado."
    },
    {
        "id": 5,
        "nome": "Haworthia",
        "preco": "40,00",
        "imagem": "haworitha.JPG",
        "descricao": "Suculenta resistente e elegante."
    },
    {
        "id": 6,
        "nome": "Lumina",
        "preco": "70,00",
        "imagem": "lumina.JPG",
        "descricao": "Planta ornamental de folhas claras e modernas."
    },
    {
        "id": 7,
        "nome": "Philodendron Ondulatum",
        "preco": "79,00",
        "imagem": "phondulatum.jpg",
        "descricao": "Planta tropical elegante com folhas marcantes. Ideal para dar destaque na decoração de ambientes internos."
    },
    {
        "id": 8,
        "nome": "Syngonium Albo Variegata",
        "preco": "150,00",
        "imagem": "singonio_albo_variegata.jpg",
        "descricao": "Planta rara com folhas variegadas em branco e verde. Muito valorizada e perfeita para colecionadores."
}

]

@app.route("/")
def inicio():
    return render_template("index.html", plantas=plantas)

@app.route("/aglaonema")
def aglaonema():
    return render_template("aglaonema.html")

@app.route("/sansevieria")
def sansevieria():
    return render_template("sansevieria.html")

@app.route("/phondulatum")
def phondulatum():
    return render_template("phondulatum.html")

@app.route("/comprar")
def comprar():
    produto = request.args.get("produto")
    preco = request.args.get("preco")
    return render_template("compra.html", produto=produto, preco=preco)

@app.route("/adicionar_carrinho")
def adicionar_carrinho():
    produto = request.args.get("produto")
    preco = request.args.get("preco")
    imagem = request.args.get("imagem")
    voltar = request.args.get("voltar", "/")

    if "carrinho" not in session:
        session["carrinho"] = []

    carrinho = session["carrinho"]

    carrinho.append({
        "produto": produto,
        "preco": preco,
        "imagem": imagem
    })

    session["carrinho"] = carrinho

    return redirect(voltar)

@app.route("/carrinho")
def carrinho():
    itens = session.get("carrinho", [])

    total = 0
    for item in itens:
        preco_limpo = item["preco"].replace("R$", "").replace(",", ".").strip()
        total += float(preco_limpo)

    return render_template("carrinho.html", itens=itens, total=total)

@app.route("/limpar_carrinho")
def limpar_carrinho():
    session["carrinho"] = []
    return redirect(url_for("carrinho"))

@app.route("/remover_item/<int:indice>")
def remover_item(indice):
    carrinho = session.get("carrinho", [])

    if 0 <= indice < len(carrinho):
        carrinho.pop(indice)
        session["carrinho"] = carrinho

    return redirect(url_for("carrinho"))

@app.route("/finalizar")
def finalizar():
    carrinho = session.get("carrinho", [])

    mensagem = "Olá, quero comprar:%0A"

    total = 0

    for item in carrinho:
        mensagem += f"- {item['produto']} (R$ {item['preco']})%0A"

        preco_limpo = item["preco"].replace(",", ".")
        total += float(preco_limpo)

    mensagem += f"%0ATotal: R$ {total:.2f}"

    numero = "5521982372110"  # <-- coloca seu número aqui (com DDI 55)

    link = f"https://wa.me/{numero}?text={mensagem}"

    return redirect(link)

@app.route("/produto/<int:id>")
def produto(id):
    planta = next((p for p in plantas if p["id"] == id), None)
    return render_template("produto.html", planta=planta)


if __name__ == "__main__":
    app.run(debug=True)