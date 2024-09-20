package org.scoula.bond;

import lombok.Data;

@Data
public class bondPriceVO {
    private String isinCd;
    private double clprPrc;
    private double clprBnfRt;
}