

 
 
 




window new WaveWindow  -name  "Waves for BMG Example Design"
waveform  using  "Waves for BMG Example Design"

      waveform add -signals /vram_32b_6144_tb/status
      waveform add -signals /vram_32b_6144_tb/vram_32b_6144_synth_inst/bmg_port/CLKA
      waveform add -signals /vram_32b_6144_tb/vram_32b_6144_synth_inst/bmg_port/ADDRA
      waveform add -signals /vram_32b_6144_tb/vram_32b_6144_synth_inst/bmg_port/DINA
      waveform add -signals /vram_32b_6144_tb/vram_32b_6144_synth_inst/bmg_port/WEA
      waveform add -signals /vram_32b_6144_tb/vram_32b_6144_synth_inst/bmg_port/CLKB
      waveform add -signals /vram_32b_6144_tb/vram_32b_6144_synth_inst/bmg_port/ADDRB
      waveform add -signals /vram_32b_6144_tb/vram_32b_6144_synth_inst/bmg_port/DOUTB

console submit -using simulator -wait no "run"
