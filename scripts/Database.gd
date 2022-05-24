extends Node


const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
const db_path = "res://database/bubble_war_server.sqlite"
var db = null

## queries ##
const SELECT_USER_BY_NAME_AND_PASSWORD = "SELECT USERS.ID AS ID, USERS.NAME AS NAME, USERS.TOTAL_SCORE AS TOTAL_SCORE, BOOSTS.NAME AS SELECTED_BOOST_NAME FROM USERS LEFT JOIN BOOSTS ON USERS.SELECTED_BOOST = BOOSTS.ID WHERE USERS.NAME = ? AND USERS.PASSWORD = ?"
const UPDATE_USER_SCORE_BY_ID = "UPDATE USERS SET TOTAL_SCORE = TOTAL_SCORE + ? WHERE ID = ?"
const SELECT_ALL_BOOSTS = "SELECT * FROM BOOSTS"
const UPDATE_USER_SELECTED_BOOST = "UPDATE USERS SET SELECTED_BOOST = ? WHERE ID = ?"
const SELECT_USER_BY_ID = "SELECT USERS.ID AS ID, USERS.NAME AS NAME, USERS.TOTAL_SCORE AS TOTAL_SCORE, BOOSTS.NAME AS SELECTED_BOOST_NAME FROM USERS LEFT JOIN BOOSTS ON USERS.SELECTED_BOOST = BOOSTS.ID WHERE USERS.ID = ?"


func _ready():
	pass


func init_db():
	if db == null:
		db = SQLite.new()
		db.path = db_path
		db.open_db()


func is_db_connected():
	return db != null


func execute_query(sql):
	if db != null:
		db.query(sql)
		return db.query_result
	return []


func execute_query_with_args(sql, args):
	if db != null:
		db.query_with_bindings(sql, args)
		return db.query_result
	return []
