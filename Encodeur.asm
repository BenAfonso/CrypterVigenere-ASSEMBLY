	

    # Saisie de la cl� par l'utilisateur
    # Texte d'entr�e � encoder :
            # Saisi par l'utilisateur
            # Via un fichier texte
    # Encodage
     
    .data
    inputKey: .asciiz "Entrez une cl� d'encodage (50 caract�res maximum): "
    chosenKey: .asciiz "La cl� choisie est : "
    firstMenu: .asciiz "Voulez vous encoder (Entrez 1) ou decoder (Entrez 2): "
    cryptChoice: .asciiz "Voulez vous encoder un fichier texte (Entrez 1) ou une phrase (Entrez 2): "
    inputText: .asciiz "\nVeuillez saisir le texte � encoder: "
    text: .space 100
    key: .space 50
    keyArray: .space 50
    textArray: .space 100
    encode: .space 100
     
    .text
     
    #########################################################################
    ######################## PROGRAMME PRINCIPAL ############################
    #########################################################################
     
    main:
            # Appel des routines
            jal menu
            move $s1,$t1
            jal input
            jal affichage
            jal typeEncodageChoix
            # beq $t1,2,cryptfile ## A MAPPER AVEC INPUT DE FICHIERS .TXT
            beq $t1,2,cryptText
            beq $s1,1,encoder
            beq $s1,2,decoder
            
            #jal encode2
		#la $t0,keyArray
		#lb $a0,1($t0)
		#li $v0,1
		#syscall
		
            # Fin du programme
            j end
            li $v0,10
           
    #########################################################################
    #################### INTERACTIONS UTILISATEUR ###########################
    #########################################################################
     
    menu:
    	la $a0, firstMenu
    	la $v0,4
    	syscall
    	la $v0,5
    	syscall
    	la $t1,($v0)
    	jr $ra
    # Routine demandant � l'utilisateur de saisir une cl� d'encryption
    # Sortie: $t0 : String, Cl� d'encryption
    input:
   	subi $sp , $sp , 4 	# Sauvegarde de l'adresse de la routine principale
	sw $ra , ( $sp )
            la $a0,inputKey
            li $v0,4
            syscall
            la $a0,key
            la $a1,50
            li $v0,8
            syscall
            la $a1, keyArray
            jal stockInArray
        lw $ra , ( $sp )	# On restaure l'adresse de la routine principale
	addi $sp , $sp , 4
	jr $ra		# Jump � la routine principale
           
	stockKeyInArray:
    		move $t0,$a0
    		move $t1,$a1
  	for:
  		lb $t2, ($t0)
		sb $t2, ($t1)
		addiu $t0, $t0, 1
		addiu $t1, $t1, 1
		bnez $t2, for
		move $v0, $a1
		jr $ra
		
           
     
    #  Routine affichant le choix de l'utilisateur pour la cl�    
    affichage:
            la $a0,chosenKey
            li $v0, 4
            syscall
            la $a0,key
            li $v0,4
            syscall
            jr $ra
     
    # Routine demandant � l'utilisateur s'il veut encoder une phrase ou un fichier texte  
    typeEncodageChoix:
            la $a0,cryptChoice
            li $v0,4
            syscall
            li $v0,5
            syscall
            la $t1,($v0)
            jr $ra
           
           
    # Encryption d'une phrase choisie      
    cryptText:
    	subi $sp , $sp , 4
	sw $ra , ( $sp )

        la $a0,inputText
        li $v0,4
        syscall
        li $a1,100
        la $a0,text	# On stock la phrase dans � l'adresse de text (100 octets maximum)
        li $v0,8
        syscall
        la $a1, textArray
 	jal stockInArray
 	la $a0, textArray
 	li $v0, 4
 	syscall
	lw $ra , ( $sp )
	addi $sp , $sp , 4
	jr $ra
	
    stockInArray:
    	move $t0,$a0 #t0 :: TEXT
    	move $t1,$a1 #t1 :: ARRAY
    	
    for2:
  	lb $t2, ($t0)
	sb $t2, ($t1)
	addiu $t0, $t0, 1
	addiu $t1, $t1, 1
	bnez $t2,for2
	move $v0, $t1
	jr $ra
		
    #########################################################
    #################### ENCODAGE ###########################
    #########################################################
    
    # Cl� stock�e dans un tableau keyArray
    # Texte stock� dans un tableau textArray
 	encoder:
 		la $t0,textArray # TEXT ARRAY
 		la $t1,keyArray # KEY ARRAY
 		la $t2,encode
	reset: 
		la $t1,keyArray
	for3:	
		lb $t3,($t0) # On prends la valeur courante de textArray et on la met dans $t2
		lb $t4,($t1) # On prends la valeur de la cl� courante
		beq $t4,10,reset
		addiu $t1,$t1,1 # On incr�mente les deux
		addiu $t0,$t0,1	
		beq $t3,10,end	
		# t4 VALEUR DE CLE ASSOCIE A CARACTERE COURANT 
		# OPERATIONS ICI
		add $t4,$t4,$t3
		bge $t4,126,plus
		jal next
	plus:
		addiu $t4,$t4,-94 # Si $t4 est >= 126, on fait -94
	next:
		la $a0,($t4) # On affiche la valeur de t3 (cl�)
		li $v0,11
		syscall
		sb $a0,encode
		# VISIBILITE
		#li $a0,0
		#li $v0,1
		#syscall
		bne $t3,10,for3 #On boucle tant que t2 n'est pas fini (texte)
		j end
		
		
#########################################################
#################### DECODAGE ###########################
#########################################################
    
    # Cl� stock�e dans un tableau keyArray
    # Texte stock� dans un tableau textArray
 	decoder:
 		la $t0,textArray # TEXT ARRAY
 		la $t1,keyArray # KEY ARRAY
 		la $t2,encode
	reset2: 
		la $t1,keyArray
	for4:	
		lb $t3,($t0) # On prends la valeur courante de textArray et on la met dans $t2
		lb $t4,($t1) # On prends la valeur de la cl� courante
		beq $t4,10,reset2
		addiu $t1,$t1,1 # On incr�mente les deux
		addiu $t0,$t0,1	
		beq $t3,10,end	
		# t4 VALEUR DE CLE ASSOCIE A CARACTERE COURANT 
		# OPERATIONS ICI
		neg $t4,$t4
		add $t4,$t3,$t4
		blez $t4,plus2
		jal next
	plus2:
		addiu $t4,$t4,94 # Si $t4 est <= 0, on fait +94
	next2:
		la $a0,($t4) # On affiche la valeur de t4 (cl�)
		li $v0,11
		syscall
		
		# VISIBILITE
		#li $a0,0
		#li $v0,1
		#syscall
		bne $t3,10,for4 #On boucle tant que t2 n'est pas fini (texte)
		j end
		
	
		
 		
   	
   	
   	
    # Fin du programme     
    end:
    
    	

