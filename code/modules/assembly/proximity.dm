//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:05

/obj/item/device/assembly/prox_sensor
	name = "proximity sensor"
	desc = "Used for scanning and alerting when someone enters a certain proximity."
	icon_state = "prox"
	m_amt = 800
	g_amt = 200
	w_amt = 50
	origin_tech = "magnets=1"

	secured = 1
	small_icon_state_left = "prox_left"
	small_icon_state_right = "prox_right"

	var/scanning = 0
	var/timing = 0
	var/time = 10

	proc
		toggle_scan()
		sense()


	activate()
		if(!..())	return 0//Cooldown check
		timing = !timing
		update_icon()
		return 0


	toggle_secure()
		secured = !secured
		if(secured)
			processing_objects.Add(src)
		else
			scanning = 0
			timing = 0
			processing_objects.Remove(src)
		update_icon()
		return secured


	HasProximity(atom/movable/AM as mob|obj)
		if (istype(AM, /obj/effect/beam))	return
		if (AM.move_speed < 12)	sense()
		return


	sense()
		if((!secured)||(!scanning)||(cooldown > 0))	return 0
		pulse(0)
		for(var/mob/O in hearers(null, null))
			O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
		cooldown = 2
		spawn(10)
			process_cooldown()
		return


	process()
		if(timing && (time >= 0))
			time--
		if(timing && time <= 0)
			timing = 0
			toggle_scan()
			time = 10
		return


	dropped()
		spawn(0)
			sense()
			return
		return


	toggle_scan()
		if(!secured)	return 0
		scanning = !scanning
		update_icon()
		return


	update_icon()
		overlays = null
		small_icon_state_overlays = list()
		if(timing)
			overlays += text("prox_timing")
			small_icon_state_overlays += text("prox_timing")
		if(scanning)
			overlays += text("prox_scanning")
			small_icon_state_overlays += text("prox_scanning")
			if(master && istype(master, /obj/item/weapon/chem_grenade))
				var/obj/item/weapon/chem_grenade/M = master
				M.c_state(1)
		else
			if(master && istype(master, /obj/item/weapon/chem_grenade))
				var/obj/item/weapon/chem_grenade/M = master
				M.c_state(0)
		if(holder)
			holder.update_icon()

		return


	Move()
		..()
		sense()
		return


	interact(mob/user as mob)//TODO: Change this to the wires thingy
		if(!secured)
			user.show_message("\red The [name] is unsecured!")
			return 0
		var/second = time % 60
		var/minute = (time - second) / 60
		var/dat = text("<TT><B>Proximity Sensor</B>\n[] []:[]\n<A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT>", (timing ? text("<A href='?src=\ref[];time=0'>Arming</A>", src) : text("<A href='?src=\ref[];time=1'>Not Arming</A>", src)), minute, second, src, src, src, src)
		dat += "<BR><A href='?src=\ref[src];scanning=1'>[scanning?"Armed":"Unarmed"]</A> (Movement sensor active when armed!)"
		dat += "<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
		dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
		user << browse(dat, "window=prox")
		onclose(user, "prox")
		return


	Topic(href, href_list)
		..()
		if(get_dist(src, usr) > 1)
			usr << browse(null, "window=prox")
			onclose(usr, "prox")
			return

		if(href_list["scanning"])
			toggle_scan()
			processing_objects.Add(src)

		if(href_list["time"])
			timing = text2num(href_list["time"])
			update_icon()
			processing_objects.Add(src)

		if(href_list["tp"])
			var/tp = text2num(href_list["tp"])
			time += tp
			time = min(max(round(time), 0), 600)

		if(href_list["close"])
			usr << browse(null, "window=prox")
			return

		if(usr)
			attack_self(usr)


		return
