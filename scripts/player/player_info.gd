extends VBoxContainer

@onready var name_name: Label = $nome
@onready var cards: Label = $cards
@onready var moedas: Label = $moedas

func update_name(nome: String):
    name_name.text = nome
    
func update_cards(nome: int):
   cards.text = str(nome)

func update_moedas(nome: int):
   moedas.text = str(nome)