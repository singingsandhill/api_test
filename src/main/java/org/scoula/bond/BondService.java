package org.scoula.bond;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.scoula.bond.bondPriceVO;

import java.util.List;

@Service
public class BondService {
    private final BondMapper bondMapper;

    @Autowired
    public BondService(BondMapper bondMapper) {
        this.bondMapper = bondMapper;
    }

    public void saveBond(BondVO bondvo) {
        bondMapper.insertBond(bondvo);
    }

    public List<bondPriceVO> getBonds() {
        return bondMapper.getAllbond();
    }

    public void saveBondPrice(String isinCd, double clprPrc) {
        bondMapper.updateBondPrice(isinCd, clprPrc);
    }

}
