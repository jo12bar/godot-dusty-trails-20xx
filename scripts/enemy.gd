## A wrapper class for easily identifying enemies through code.
##
## Also includes some basic code & interfaces common to all enemies.
class_name Enemy
extends CharacterBody2D

## Fired whenever this enemy dies.
signal enemy_death
