//
//  GameData.swift
//  emojiWords
//
//  Created by Tyler Stickler on 4/20/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

import Foundation

class GameData {
    // Each key maps to another dictionary where the key is the name of the level pack
    // and the array of strings is an array containing each level string for that pack.
    static var levels = ["watermelon" : ["6%uptime_lovesick_ghoststory_phoenix_downtoearth_%me_moa_ju_ell_arth_dow_ae_looc_stst_ntoe_tli_fo_ory_pe_love_pho_mp_gho_ix_en_up_cep_sick_ti_",                                                                                                   "6%deviledeggs_lemonade_golfclub_icebox_corndog_%iceb_lro_arp_tli_lede_corn_ae_looc_dog_ub_go_lf_ggs_ju_na_devi_fo_cep_de_mo_ox_le_ell_cl_",
                                         "6%taxidriver_friday_brainstorm_firetruck_redeye_%brai_dri_ay_fo_ju_taxi_red_apil_nsto_uck_eye_ell_retr_ae_frid_lro_arp_pe_fi_tli_mp_looc_rm_ver_",
                                         "6%bluemoon_disney_lionking_elsa_hideandseek_%nk_cep_mp_ue_moon_ands_hi_eek_tli_pe_ju_di_el_nil_ing_ey_de_fo_moa_ae_sa_sn_bl_lio_",
                                         "6%tulips_dentist_catfood_snowbird_applebees_%looc_ow_arp_moa_ju_app_fo_ti_st_lips_den_tu_leb_mp_rd_ell_ae_bi_catf_ees_ood_nil_sn_tli_"]]
    static var defaults = UserDefaults.standard
}
