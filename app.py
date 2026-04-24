from flask import Flask, render_template, request, redirect, url_for, session
import urllib.parse
import os
import psycopg2
from werkzeug.utils import secure_filename

app = Flask(__name__)
app.secret_key = "sereia_verdinha_chave"

DATABASE_URL = os.environ.get(
    "DATABASE_URL",
    "postgresql://postgres:SereiaRe8004@db.mlupsmpiynbgrtxeqzvv.supabase.co:5432/postgres"
)

SENHA_ADMIN = os.environ.get("SENHA_ADMIN", "Renata80$")

PASTA_IMAGENS = os.path.join("static", "img")
EXTENSOES_PERMITIDAS = {"png", "jpg", "jpeg", "webp"}

FRETES = {
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


def conectar_db():
    return psycopg2.connect(DATABASE_URL)


def arquivo_permitido(nome_arquivo):
    return "." in nome_arquivo and nome_arquivo.rsplit(".", 1)[1].lower() in EXTENSOES_PERMITIDAS


def carregar_plantas():
    conn = conectar_db()
    cur = conn.cursor()

    cur.execute("""
        SELECT id, nome, preco, image, descricao, estoque, luz, rega, ambiente, dificuldade
        FROM plantas
        ORDER BY id
    """)

    dados = cur.fetchall()

    cur.close()
    conn.close()

    plantas = []

    for p in dados:
        plantas.append({
            "id": p[0],
            "nome": p[1],
            "preco": p[2],
            "image": p[3],
            "descricao": p[4],
            "estoque": p[5],
            "luz": p[6],
            "rega": p[7],
            "ambiente": p[8],
            "dificuldade": p[9]
        })

    return plantas


def atualizar_estoque_banco(id_planta, novo_estoque):
    conn = conectar_db()
    cur = conn.cursor()

    cur.execute(
        "UPDATE plantas SET estoque = %s WHERE id = %s",
        (novo_estoque, id_planta)
    )

    conn.commit()
    cur.close()
    conn.close()


def adicionar_planta_banco(planta):
    conn = conectar_db()
    cur = conn.cursor()

    cur.execute("""
        INSERT INTO plantas (nome, preco, image, descricao, estoque, luz, rega, ambiente, dificuldade)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (
        planta["nome"],
        planta["preco"],
        planta["image"],
        planta["descricao"],
        planta["estoque"],
        planta["luz"],
        planta["rega"],
        planta["ambiente"],
        planta["dificuldade"]
    ))

    conn.commit()
    cur.close()
    conn.close()


def estoque_suficiente(itens_carrinho):
    plantas = carregar_plantas()

    for item_carrinho in itens_carrinho:
        planta = next((p for p in plantas if p["id"] == item_carrinho["id"]), None)

        if not planta:
            return False

        if planta["estoque"] < item_carrinho["quantidade"]:
            return False

    return True


def baixar_estoque(itens_carrinho):
    plantas = carregar_plantas()

    for item_carrinho in itens_carrinho:
        planta = next((p for p in plantas if p["id"] == item_carrinho["id"]), None)

        if planta:
            novo_estoque = planta["estoque"] - item_carrinho["quantidade"]
            novo_estoque = max(0, novo_estoque)
            atualizar_estoque_banco(planta["id"], novo_estoque)


def admin_logado():
    return session.get("admin_logado") is True


def preco_para_float(preco_str):
    return float(preco_str.replace("R$", "").replace(",", ".").strip())


def total_itens_carrinho():
    carrinho = session.get("carrinho", [])
    return sum(item.get("quantidade", 1) for item in carrinho)


@app.context_processor
def injetar_dados_globais():
    return {
        "qtd_carrinho": total_itens_carrinho()
    }


@app.route("/")
def inicio():
    plantas = carregar_plantas()
    return render_template("index.html", plantas=plantas)


@app.route("/admin/login", methods=["GET", "POST"])
def admin_login():
    erro = None

    if request.method == "POST":
        senha = request.form.get("senha", "")

        if senha == SENHA_ADMIN:
            session["admin_logado"] = True
            return redirect(url_for("admin_estoque"))
        else:
            erro = "Senha incorreta."

    return render_template("admin_login.html", erro=erro)


@app.route("/admin/logout")
def admin_logout():
    session.pop("admin_logado", None)
    return redirect(url_for("inicio"))


@app.route("/admin/estoque", methods=["GET", "POST"])
def admin_estoque():
    if not admin_logado():
        return redirect(url_for("admin_login"))

    plantas = carregar_plantas()

    if request.method == "POST":
        for planta in plantas:
            campo = f'estoque_{planta["id"]}'

            if campo in request.form:
                try:
                    novo_estoque = int(request.form[campo])
                except ValueError:
                    novo_estoque = 0

                atualizar_estoque_banco(planta["id"], novo_estoque)

        return redirect(url_for("admin_estoque"))

    return render_template("admin_estoque.html", plantas=plantas)


@app.route("/admin/adicionar", methods=["GET", "POST"])
def admin_adicionar():
    if not admin_logado():
        return redirect(url_for("admin_login"))

    if request.method == "POST":
        arquivo = request.files.get("image")
        nome_imagem = ""

        if arquivo and arquivo.filename:
            if not arquivo_permitido(arquivo.filename):
                return "Formato de imagem não permitido. Use png, jpg, jpeg ou webp."

            nome_seguro = secure_filename(arquivo.filename)
            caminho_imagem = os.path.join(PASTA_IMAGENS, nome_seguro)
            arquivo.save(caminho_imagem)
            nome_imagem = nome_seguro

        nova_planta = {
            "nome": request.form.get("nome", "").strip(),
            "preco": request.form.get("preco", "").strip(),
            "image": nome_imagem,
            "descricao": request.form.get("descricao", "").strip(),
            "estoque": int(request.form.get("estoque", 0)),
            "luz": request.form.get("luz", "").strip(),
            "rega": request.form.get("rega", "").strip(),
            "ambiente": request.form.get("ambiente", "").strip(),
            "dificuldade": request.form.get("dificuldade", "").strip()
        }

        adicionar_planta_banco(nova_planta)

        return redirect(url_for("admin_estoque"))

    return render_template("admin_adicionar.html")


@app.route("/produto/<int:id>")
def produto(id):
    plantas = carregar_plantas()
    planta = next((p for p in plantas if p["id"] == id), None)

    if planta is None:
        return "Produto não encontrado", 404

    return render_template("produto.html", planta=planta)


@app.route("/adicionar_carrinho/<int:id>")
def adicionar_carrinho(id):
    plantas = carregar_plantas()
    planta = next((p for p in plantas if p["id"] == id), None)

    if not planta:
        return "Produto não encontrado", 404

    voltar = request.args.get("voltar", url_for("inicio"))

    if planta["estoque"] <= 0:
        return redirect(voltar)

    if "carrinho" not in session:
        session["carrinho"] = []

    carrinho = session["carrinho"]
    item_existente = next((item for item in carrinho if item["id"] == id), None)

    if item_existente:
        item_existente["quantidade"] += 1
    else:
        carrinho.append({
            "id": planta["id"],
            "nome": planta["nome"],
            "preco": planta["preco"],
            "imagem": planta["image"],
            "quantidade": 1
        })

    session["carrinho"] = carrinho
    session.modified = True

    return redirect(f"{voltar}?adicionado=1")


@app.route("/carrinho")
def carrinho():
    itens = session.get("carrinho", [])

    total = 0
    for item in itens:
        total += preco_para_float(item["preco"]) * item["quantidade"]

    return render_template("carrinho.html", itens=itens, total=total)


@app.route("/limpar_carrinho")
def limpar_carrinho():
    session["carrinho"] = []
    session.modified = True
    return redirect(url_for("carrinho"))


@app.route("/remover_item/<int:indice>")
def remover_item(indice):
    carrinho = session.get("carrinho", [])

    if 0 <= indice < len(carrinho):
        carrinho.pop(indice)
        session["carrinho"] = carrinho
        session.modified = True

    return redirect(url_for("carrinho"))


@app.route("/finalizar")
def finalizar():
    itens = session.get("carrinho", [])

    rua = request.args.get("rua", "")
    numero = request.args.get("numero", "")
    complemento = request.args.get("complemento", "")
    bairro = request.args.get("bairro", "")

    subtotal = 0
    for item in itens:
        subtotal += preco_para_float(item["preco"]) * item["quantidade"]

    frete = FRETES.get(bairro) if bairro else None
    total = subtotal + frete if frete is not None else subtotal

    return render_template(
        "finalizar.html",
        itens=itens,
        subtotal=f"{subtotal:.2f}".replace(".", ","),
        frete=frete,
        total=f"{total:.2f}".replace(".", ","),
        bairros=FRETES,
        bairro_selecionado=bairro,
        rua=rua,
        numero=numero,
        complemento=complemento
    )


@app.route("/confirmar_pedido")
def confirmar_pedido():
    itens = session.get("carrinho", [])

    if not itens:
        return redirect(url_for("carrinho"))

    if not estoque_suficiente(itens):
        return "Algum item do carrinho não tem estoque suficiente. Volte e atualize o carrinho."

    rua = request.args.get("rua", "")
    numero = request.args.get("numero", "")
    complemento = request.args.get("complemento", "")
    bairro = request.args.get("bairro", "")

    subtotal = 0
    for item in itens:
        subtotal += preco_para_float(item["preco"]) * item["quantidade"]

    frete = FRETES.get(bairro) if bairro else None
    total = subtotal + frete if frete is not None else subtotal

    mensagem = "*Sereia Verdinha*\n\n"
    mensagem += "*Pedido:*\n"

    for item in itens:
        mensagem += f"• {item['nome']} x{item['quantidade']} - R$ {item['preco']}\n"

    mensagem += f"\n*Subtotal:* R$ {subtotal:.2f}".replace(".", ",")

    if frete is not None:
        mensagem += f"\n*Frete:* R$ {frete:.2f}".replace(".", ",")
        mensagem += f"\n*Total:* R$ {total:.2f}".replace(".", ",")

    if rua or numero or complemento or bairro:
        mensagem += "\n\n*Endereço:*\n"
        mensagem += f"Rua: {rua}\n"
        mensagem += f"Número: {numero}\n"

        if complemento:
            mensagem += f"Complemento: {complemento}\n"

        mensagem += f"Bairro: {bairro}"

    baixar_estoque(itens)

    session["carrinho"] = []
    session.modified = True

    link_whatsapp = f"https://wa.me/5521982372110?text={urllib.parse.quote(mensagem)}"
    return redirect(link_whatsapp)


if __name__ == "__main__":
    app.run(debug=True)