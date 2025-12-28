extends VBoxContainer

@onready var name_name: Label = $nome
@onready var moedas: Label = $moedas
@onready var cards: HBoxContainer  = $cards

func update_name(nome: String):
   name_name.text = nome

func update_moedas(nome: int):
   moedas.text += str(nome)
