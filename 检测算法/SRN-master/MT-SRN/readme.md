MT-SRN is updated from SRN for joint edge and symmetry detection. The architecture is
![MT-SRN](https://zyjmhw-sn3301.files.1drv.com/y4m21xDDP1TtxkIidB-pzp-tSVyKoKOVir2J2kOcd1RcybwesKJiq8_f9bwcYFBswltAcj8QxWs1iofhSmYB1vDLttsNjBZLUrwaZj3fWLSPnCX3qI3zqGX5l3KTeGCTGFhwHQmjyGh6SpshbJdcrtRsprFSw25UnqXAY0fgqWnpLad3otY8D_RKk1JY35S5OKKnHJXIbnwjE0f0_iSaif4LQ?width=2649&height=1261&cropmode=none)

We take alternative training on edge branch and symmetry branch. Interestingly, the performance of joint learned MT-SRN is better than the individual SRN.


<table>
   <tr>
      <td></td>
      <td>Datasets</td>
      <td>ODS (edge)</td>
      <td>F-measure (symmetry)</td>
   </tr>
   <tr>
      <td>SRN</td>
      <td>BSDS500</td>
      <td>0.782</td>
      <td>——</td>
   </tr>
   <tr>
      <td></td>
      <td>SYMMAX</td>
      <td>——</td>
      <td>0.446</td>
   </tr>
   <tr>
      <td></td>
      <td>WH-SYMMAX</td>
      <td>——</td>
      <td>0.78</td>
   </tr>
   <tr>
      <td></td>
      <td>SK506</td>
      <td>——</td>
      <td>0.632</td>
   </tr>
   <tr>
      <td></td>
      <td>Sym-PASCAL</td>
      <td>——</td>
      <td>0.443</td>
   </tr>
   <tr>
      <td>MT-SRN</td>
      <td>BSDS500+SYMMAX</td>
      <td>0.785</td>
      <td>0.464</td>
   </tr>
   <tr>
      <td></td>
      <td>BSDS500+WHSYMMAX</td>
      <td>0.779</td>
      <td>0.807</td>
   </tr>
   <tr>
      <td></td>
      <td>BSDS500+SK506</td>
      <td>0.786</td>
      <td>0.639</td>
   </tr>
   <tr>
      <td></td>
      <td>BSDS500+Sym-PASCAL</td>
      <td>0.784</td>
      <td>0.453</td>
   </tr>
</table>
