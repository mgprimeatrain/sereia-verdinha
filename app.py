from flask import Flask, render_template, request, redirect, url_for, session
import urllib.parse

app = Flask(__name__)
app.secret_key = "sereia_verdinha_chave"

SENHA_ADMIN = "Renata80$"

fretes = {
    "Vila Isabel": 10,
    "Grajaú": 0,
    "Tijuca": 10,
    "Méier": 10,
    "Engenho Novo": 10,
    "Ipanema": 15,
    "Copacabana": 15,
    "Leblon": 15,
    "Botafogo": 15,
    "Flamengo": 15,
    "Laranjeiras": 15,
    "Barra": 20
}

plantas = [
    {
        "id": 1,
        "nome": "Alocasia Cuprea",
        "preco": "120,00",
        "image": "alocasia_cuprea.JPG",
        "descricao": "Folhas metálicas únicas e muito decorativas.",
        "estoque": 0
    },
    {
        "id": 2,
        "nome": "Asplênio Rabo de Peixe",
        "preco": "45,00",
        "image": "asplenio_rabo_de_peixe.JPG",
        "descricao": "Planta verde vibrante ideal para interiores.",
        "estoque": 0
    },
    {
        "id": 3,
        "nome": "Cacto Gymnocalycium",
        "preco": "35,00",
        "image": "cacto_gymnocalycium.JPG",
        "descricao": "Cacto compacto e fácil de cuidar.",
        "estoque":0
    },
    {
        "id": 4,
        "nome": "Criptanthus",
        "preco": "50,00",
        "image": "criptanthus.JPG",
        "descricao": "Planta exótica com formato estrelado.",
        "estoque":0
    },
    {
        "id": 5,
        "nome": "Haworthia",
        "preco": "40,00",
        "image": "haworitha.JPG",
        "descricao": "Suculenta resistente e elegante.",
        "estoque": 0
    },
    {
        "id": 6,
        "nome": "Lumina",
        "preco": "70,00",
        "image": "lumina.JPG",
        "descricao": "Planta ornamental de folhas claras e modernas.",
        "estoque":0
    },
    {
        "id": 7,
        "nome": "Philodendron Ondulatum",
        "preco": "79,00",
        "image": "phondulatum.jpg",
        "descricao": "Planta tropical elegante com folhas marcantes. Ideal para dar destaque na decoração de ambientes internos.",
        "estoque": 0
    },
    {
        "id": 8,
        "nome": "Syngonium Albo Variegata",
        "preco": "150,00",
        "image": "singonio_albo_variegata.jpg",
        "descricao": "Planta rara com folhas variegadas em branco e verde. Muito valorizada e perfeita para colecionadores.",
        "estoque": 0
    },
    {
    "id": 9,
    "nome": "Filodendro Seloun Gold",
    "preco": "70,00",
    "image": "filodendro_seloun_gold.JPG",
    "descricao": "O Filodendro Selloum Gold traz destaque e sofisticação com suas folhas grandes e recortadas em tom dourado, criando um visual tropical moderno.",
    "estoque": 0
    

    },
    {
    "id": 10,
    "nome": "Jiboia Neon",
    "preco": "45,00",
    "image": "jiboia.jpg",
    "descricao": "A Jiboia é uma planta fácil de cuidar, com folhas verdes que trazem charme e leveza ao ambiente.",
    "estoque": 1
},
{
    "id": 11,
    "nome": "Mini Costela de Eva",
    "preco": "39,90",
    "image": "mini_costela_de_eva.jpg",
    "descricao": "A Mini Costela de Eva é compacta e elegante, com folhas recortadas que dão um toque moderno e sofisticado ao ambiente.",
    "estoque":0
},
{
    "id": 12,
    "nome": "Antúrio Plowmani Médio",
    "preco": "79,90",
    "image": "anturio_plowmani_medio.jpg",
    "descricao": "O Antúrio Plowmani Médio se destaca pelas folhas longas e onduladas, trazendo um visual exótico e marcante para qualquer espaço.",
    "estoque":0
}
]

@app.route("/")
def inicio():
    return render_template("index.html", plantas=plantas)

@app.route("/admin/login", methods=["GET", "POST"])
def admin_login():
    erro = None

    if request.method == "POST":
        senha = request.form.get("senha")

        if senha == SENHA_ADMIN:
            session["admin_logado"] = True
            return redirect(url_for("admin_estoque"))
        else:
            erro = "Senha incorreta."

    return render_template("admin_login.html", erro=erro)

@app.route("/admin/logout")
def admin_logout():
    session.pop("admin_logado", None)
    return redirect(url_for("index"))

@app.route("/admin/estoque", methods=["GET", "POST"])
def admin_estoque():
    if not session.get("admin_logado"):
        return redirect(url_for("admin_login"))

    if request.method == "POST":
        planta_id = int(request.form.get("id"))
        novo_estoque = int(request.form.get("estoque"))

        for planta in plantas:
            if planta["id"] == planta_id:
                planta["estoque"] = novo_estoque
                break

        return redirect(url_for("admin_estoque"))

    return render_template("admin_estoque.html", plantas=plantas)

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

    if "?" in voltar:
        return redirect(f"{voltar}&adicionado=1")
    return redirect(f"{voltar}?adicionado=1")

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
    return redirect("/carrinho")

@app.route("/remover_item/<int:indice>")
def remover_item(indice):
    carrinho = session.get("carrinho", [])

    if 0 <= indice < len(carrinho):
        carrinho.pop(indice)
        session["carrinho"] = carrinho

    return redirect(url_for("carrinho"))

@app.route("/finalizar")
def finalizar():
    itens = session.get("carrinho", [])

    rua = request.args.get("rua", "")
    numero = request.args.get("numero", "")
    complemento = request.args.get("complemento", "")
    bairro = request.args.get("bairro", "")

    # 💰 tabela de frete
    fretes = {
        "Vila Isabel": 10,
        "Grajaú": 0,
        "Tijuca": 10,
        "Méier": 10,
        "Engenho Novo": 10,
        "Ipanema": 15,
        "Copacabana": 15,
        "Leblon": 15,
        "Botafogo": 15,
        "Flamengo": 15,
        "Laranjeiras": 15,
        "Barra": 20
    }

    # 🧠 cálculo
    subtotal = sum(float(item["preco"].replace(",", ".")) for item in itens)

    frete = fretes.get(bairro) if bairro else None
    total = subtotal + frete if frete is not None else subtotal

    # 📲 mensagem WhatsApp
    mensagem = " *Sereia Verdinha* "

    if itens:
        mensagem += " *Pedido:*"

        for item in itens:
            mensagem += f"• {item['produto']} - R$ {item['preco']}\n"

        mensagem += f" *Subtotal:* R$ {subtotal:.2f}".replace(".", ",")

        if frete is not None:
            mensagem += f" *Frete:* R$ {frete:.2f}".replace(".", ",")
            mensagem += f" *Total:* R$ {total:.2f}".replace(".", ",")

    # 📍 endereço
    if rua or numero or complemento or bairro:
        mensagem += " *Endereço:*\n"
        mensagem += f"Rua: {rua}\n"
        mensagem += f"Número: {numero}\n"

        if complemento:
            mensagem += f"Complemento: {complemento}\n"

        mensagem += f"Bairro: {bairro}"

    # 🔥 CORREÇÃO PRINCIPAL (EMOJIS + URL)
    link_whatsapp = f"https://wa.me/5521982372110?text={urllib.parse.quote(mensagem)}"

    return render_template(
        "finalizar.html",
        itens=itens,
        subtotal=f"{subtotal:.2f}".replace(".", ","),
        frete=frete,
        total=f"{total:.2f}".replace(".", ","),
        bairros=fretes,
        bairro_selecionado=bairro,
        rua=rua,
        numero=numero,
        complemento=complemento,
        link_whatsapp=link_whatsapp
    )

@app.route("/produto/<int:id>")
def produto(id):
    planta = next((p for p in plantas if p["id"] == id), None)

    if planta is None:
        return "Produto não encontrado", 404

    return render_template("produto.html", planta=planta)

if __name__ == "__main__":
    app.run(debug=True)