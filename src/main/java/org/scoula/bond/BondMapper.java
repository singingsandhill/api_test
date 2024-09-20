package org.scoula.bond;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface BondMapper {
    void insertBond(BondVO bondvo);

    List<bondPriceVO> getAllbond();
    void updateBondPrice(@Param("isinCd") String isinCd, @Param("clprPrc") double clprPrc);

}
